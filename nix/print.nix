{
  pkgs,
  src,
  oi-wiki-export,
  typst,
  # Unix timestamp the cover date is derived from.  Nix normally pins
  # `SOURCE_DATE_EPOCH` to 1980-01-01 for reproducible builds and Typst uses it
  # for `datetime.today()`, which would put that date on the cover.  The flake
  # passes the revision timestamp here, so the same revision always produces
  # the same PDF and the cover shows a sensible date.
  sourceDateEpoch ? 0,
}:

# Printable PDF of the whole book.
#
# The conversion tooling (Markdown -> Typst) is not vendored in this
# repository: it is taken from the `oi-wiki-export` flake input and only
# patched with the pstrode specific bits in `print/`.  Bumping the input with
#
#   nix flake update oi-wiki-export
#
# therefore tracks upstream, and a conflicting upstream change makes the build
# fail loudly while applying the patches.
let
  nodePackage =
    {
      name,
      dir,
      # Extra shell commands run after `npm install`, before `node_modules` is
      # copied to the store.  Used to patch installed dependencies.
      afterInstall ? "",
    }:
    pkgs.buildNpmPackage {
      pname = "pstrode-print-${name}-node-modules";
      version = "0.1.0";
      src = "${oi-wiki-export}/${dir}";
      npmDeps = pkgs.importNpmLock { npmRoot = "${oi-wiki-export}/${dir}"; };
      npmConfigHook = pkgs.importNpmLock.npmConfigHook;
      dontNpmBuild = true;
      installPhase = ''
        runHook preInstall
        ${afterInstall}
        mkdir -p "$out"
        cp -r node_modules "$out/node_modules"
        runHook postInstall
      '';
    };

  # `oi-wiki-export-typst/index.js` imports the sibling `remark-*` directories,
  # so each package keeps its own `node_modules`, like upstream CI does.
  exportModules = nodePackage {
    name = "oi-wiki-export-typst";
    dir = "oi-wiki-export-typst";
    # remark-details 5 only accepts the pymdown `???` syntax; teach it the
    # mkdocs `!!!` admonition syntax again.
    afterInstall = ''
      patch -p1 -d node_modules/remark-details <${../print/patches/remark-details-admonitions.patch}
    '';
  };
  remarkTypstModules = nodePackage {
    name = "remark-typst";
    dir = "remark-typst";
  };
  remarkSnippetModules = nodePackage {
    name = "remark-snippet";
    dir = "remark-snippet";
  };

  # Pages that are part of the website but must not end up in the printed book.
  # Entries are paths relative to `docs/`; a trailing slash excludes a whole
  # directory.  The pages are dropped from the navigation for the export, so
  # chapters that become empty disappear and the remaining ones are renumbered.
  excludedPages = [
    # The home page is front matter, not part of the book.
    "index.md"
    # Nothing from the intro/ directory is printed.
    "intro/"
  ];
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "pstrode-print";
  version = "0.1.0";

  inherit src;

  nativeBuildInputs = with pkgs; [
    nodejs
    typst
    imagemagick
    librsvg
    libwebp
    patch
  ];

  buildPhase = ''
    runHook preBuild

    export HOME=$TMPDIR

    work=$TMPDIR/oi-wiki-export
    mkdir -p "$work"
    cp -r ${oi-wiki-export}/oi-wiki-export-typst "$work/"
    cp -r ${oi-wiki-export}/remark-typst "$work/"
    cp -r ${oi-wiki-export}/remark-snippet "$work/"
    chmod -R u+w "$work"

    (
      cd "$work"
      # `remark-details-admonitions.patch` targets an installed npm package
      # and is applied by the `exportModules` derivation instead.
      for patch in ${../print/patches}/0*.patch; do
        echo "applying $(basename "$patch")"
        patch -p1 <"$patch"
      done
    )

    cp ${../print/pstrode-export.typ} "$work/oi-wiki-export-typst/pstrode-export.typ"
    cp ${../print/pstron.svg} "$work/oi-wiki-export-typst/pstron.svg"

    cp -r ${exportModules}/node_modules "$work/oi-wiki-export-typst/node_modules"
    cp -r ${remarkTypstModules}/node_modules "$work/remark-typst/node_modules"
    cp -r ${remarkSnippetModules}/node_modules "$work/remark-snippet/node_modules"

    docroot=$TMPDIR/pstrode
    mkdir -p "$docroot"
    cp -r "$src/docs" "$docroot/docs"
    cp "$src/mkdocs.yml" "$docroot/mkdocs.yml"
    # `remark-snippet` expands `--8<--` snippets in place.
    chmod -R u+w "$docroot"

    (
      cd "$work/oi-wiki-export-typst"
      export PSTRODE_EXPORT_EXCLUDE="${pkgs.lib.concatStringsSep "," excludedPages}"
      node index.js "$docroot"

      # Typst takes `datetime.today()` from SOURCE_DATE_EPOCH, which Nix pins
      # to 1980-01-01; override it with the revision date for the cover.
      unset SOURCE_DATE_EPOCH
      ${pkgs.lib.optionalString (sourceDateEpoch > 0) ''
        export SOURCE_DATE_EPOCH=${toString sourceDateEpoch}
      ''}
      typst compile pstrode-export.typ pstrode.pdf
    )

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp "$TMPDIR/oi-wiki-export/oi-wiki-export-typst/pstrode.pdf" "$out/pstrode.pdf"
    runHook postInstall
  '';

  meta = {
    description = "pstrode printable PDF";
    homepage = "https://cp.feynmach.com";
  };
}
