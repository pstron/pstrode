{
  description = "pstrode - pstron's XCPC algorithm templates and notes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Upstream tool that converts the MkDocs sources to Typst/PDF.  It is not a
    # flake, it is only used as a source tree that `print/patches` is applied to.
    oi-wiki-export = {
      url = "github:OI-wiki/OI-Wiki-export";
      flake = false;
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      oi-wiki-export,
      treefmt-nix,
      ...
    }:
    let
      lib = nixpkgs.lib;

      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forEachSystem = lib.genAttrs systems;
      pkgsFor = system: import nixpkgs { inherit system; };

      # Flake source, excluding VCS metadata, build results and editor cruft.
      src = lib.cleanSource ./.;

      treefmtModule =
        { pkgs, ... }:
        {
          projectRootFile = "flake.nix";

          programs.nixfmt = {
            enable = true;
            package = pkgs.nixfmt;
          };
        };

      treefmtEval = forEachSystem (system: treefmt-nix.lib.evalModule (pkgsFor system) treefmtModule);

      perSystem = forEachSystem (
        system:
        let
          pkgs = pkgsFor system;
          typst = import ./nix/typst.nix { inherit pkgs; };
          site = import ./nix/site.nix { inherit pkgs src; };
          print = import ./nix/print.nix {
            inherit
              pkgs
              src
              oi-wiki-export
              typst
              ;
            # Cover date of the PDF: the revision timestamp keeps it
            # deterministic for a given revision.
            sourceDateEpoch = self.lastModified or 0;
          };
          mkdocs = pkgs.python3.withPackages (
            ps: with ps; [
              mkdocs
              mkdocs-material
              pymdown-extensions
            ]
          );
        in
        {
          inherit
            pkgs
            typst
            site
            print
            mkdocs
            ;
        }
      );
    in
    {
      packages = forEachSystem (
        system:
        let
          inherit (perSystem.${system}) site print;
        in
        {
          inherit site print;
          default = site;
        }
      );

      devShells = forEachSystem (
        system:
        let
          inherit (perSystem.${system}) pkgs mkdocs typst;
          treefmt = treefmtEval.${system}.config.build.wrapper;
        in
        {
          default = pkgs.mkShellNoCC {
            name = "pstrode-dev";

            packages = with pkgs; [
              # Site
              mkdocs
              uv

              # Print
              nodejs
              typst
              imagemagick
              librsvg
              libwebp
              poppler-utils

              # Deploy
              wrangler

              # Tooling
              treefmt
              nixfmt
              git
              jq
            ];

            shellHook = ''
              printf '\n'
              printf 'pstrode development shell\n'
              printf '  nix build .#site            Build the static site\n'
              printf '  nix build .#print           Build the printable PDF\n'
              printf '  nix run .#serve             Preview the site locally\n'
              printf '  nix run .#deploy -- result  Deploy ./result to Cloudflare Pages\n'
              printf '  mkdocs build / mkdocs serve / typst compile\n'
              printf '\n'
            '';
          };
        }
      );

      apps = forEachSystem (
        system:
        let
          inherit (perSystem.${system}) pkgs mkdocs print;

          mkApp = name: description: package: {
            type = "app";
            program = "${package}/bin/${name}";
            meta.description = description;
          };

          serve = pkgs.writeShellApplication {
            name = "pstrode-serve";
            runtimeInputs = [ mkdocs ];
            text = ''
              exec mkdocs serve "$@"
            '';
          };

          deploy = pkgs.writeShellApplication {
            name = "pstrode-deploy";
            runtimeInputs = [ pkgs.wrangler ];
            text = ''
              site="''${1:-result}"
              project="''${CLOUDFLARE_PAGES_PROJECT:-pstrode}"

              if [ ! -d "$site" ]; then
                echo "error: '$site' is not a directory; build the site first with 'nix build .#site'" >&2
                exit 1
              fi

              exec wrangler pages deploy "$site" --project-name "$project"
            '';
          };

          render = pkgs.writeShellApplication {
            name = "pstrode-print";
            runtimeInputs = [ pkgs.coreutils ];
            text = ''
              target="''${1:-pstrode.pdf}"
              cp ${print}/pstrode.pdf "$target"
              chmod u+w "$target"
              echo "wrote $target"
            '';
          };

          serveApp = mkApp "pstrode-serve" "Preview the pstrode site locally" serve;
        in
        {
          default = serveApp;
          serve = serveApp;
          deploy = mkApp "pstrode-deploy" "Deploy a built site to Cloudflare Pages" deploy;
          render = mkApp "pstrode-print" "Build the printable PDF and copy it to a path" render;
        }
      );

      formatter = forEachSystem (system: treefmtEval.${system}.config.build.wrapper);

      checks = forEachSystem (
        system:
        let
          packages = self.packages.${system};
          treefmt = treefmtEval.${system};
        in
        {
          inherit (packages) site print;
          formatting = treefmt.config.build.check self;
        }
      );
    };
}
