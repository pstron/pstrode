{ pkgs }:

# Typst with the `@preview` packages and fonts used by the print templates
# baked in, so that `typst compile` works without network access.
pkgs.typst.wrapper {
  packages =
    ps: with ps; [
      gentle-clues_1_3_1
      linguify_0_5_0
      mitex_0_2_7
      tablex_0_0_9
    ];
  fonts = with pkgs; [
    crimson-pro
    dejavu_fonts
    lxgw-wenkai
    newcomputermodern
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
  ];
}
