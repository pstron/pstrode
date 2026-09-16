{ pkgs, src }:

# Static site built with Material for MkDocs.
pkgs.stdenvNoCC.mkDerivation {
  pname = "pstrode-site";
  version = "0.2.0";

  inherit src;

  nativeBuildInputs = [
    (pkgs.python3.withPackages (
      ps: with ps; [
        mkdocs
        mkdocs-material
        pymdown-extensions
      ]
    ))
  ];

  buildPhase = ''
    runHook preBuild

    export HOME=$TMPDIR
    mkdocs build --site-dir "$out"

    runHook postBuild
  '';

  dontInstall = true;

  meta = {
    description = "pstrode static site";
    homepage = "https://cp.feynmach.com";
  };
}
