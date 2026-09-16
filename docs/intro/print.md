本项目的打印功能基于 [OI-Wiki-export](https://github.com/OI-wiki/OI-Wiki-export) ，将整个站点的文档导出为印刷质量的 PDF。

上游工具通过 Nix flake input 固定版本，pstrode 的定制都放在 `print/` 目录中，因此可以方便地跟随上游更新。

## 使用 Nix 构建

仓库提供了 Nix flake，直接构建打印用的 PDF：

```sh
nix build .#print
```

生成的 PDF 位于 `result/pstrode.pdf` 。

也可以把 PDF 复制到指定位置：

```sh
nix run .#print -- pstrode.pdf
```

进入包含完整工具链的开发环境：

```sh
nix develop
```

开发环境中提供了 Typst、Node.js、imagemagick、librsvg、libwebp、所需字体以及 OI-Wiki-export 所需的依赖。

## 定制说明

- `print/pstrode-export.typ` ：文档模板，包含封面、双栏目录、内部引用页码修正等；
- `print/pstron.svg` ：封面使用的 logo；
- `print/patches/` ：应用到上游导出工具的最小补丁，包括适配 nixpkgs 中 Typst 版本的改动、把外部链接改为脚注、支持 `!!! note` 等提示框语法等。

PDF 中不会包含首页和 `docs/intro/` 下的内容，其余章节会作为第一章开始重新编号。需要排除的页面在 `nix/print.nix` 的 `excludedPages` 中配置，由导出脚本的 `PSTRODE_EXPORT_EXCLUDE` 环境变量生效。

## 跟随上游更新

`flake.lock` 中固定了 OI-Wiki-export 的版本，更新到上游最新版本：

```sh
nix flake update oi-wiki-export
nix build .#print
```

如果上游改动与 `print/patches/` 冲突，构建会在打补丁时失败，此时需要根据上游的改动调整补丁或模板。

## 故障排除

- 在导出过程中可能会存在部分图片导出不成功的问题，目前尚未解决。
