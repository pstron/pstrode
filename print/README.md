# pstrode-print

将 pstrode 导出为印刷质量 PDF 的定制部分。

实际的转换工具来自 [OI-Wiki-export](https://github.com/OI-wiki/OI-Wiki-export) ，通过 Nix flake input 固定版本，本目录只保存 pstrode 自己的改动。

## 内容

| 文件 | 说明 |
| - | - |
| `pstrode-export.typ` | 文档模板：封面、双栏目录、内部引用页码修正、正文排版 |
| `pstron.svg` | 封面 logo |
| `patches/0001-typst-0.15-compat.patch` | 适配 nixpkgs 中 Typst 版本的 `@preview` 包版本与字体名 |
| `patches/0002-external-links-as-footnotes.patch` | 外链改为「脚注 + 原 URL」，去掉尾部的参考资料列表与二维码 |
| `patches/0003-drop-unused-mathjax-import.patch` | 去掉上游未使用的 `remark-mathjax` import，避免打包它的一大批依赖 |
| `patches/0004-exclude-pages-from-print.patch` | 支持通过 `PSTRODE_EXPORT_EXCLUDE` 排除页面；并修复 `getLabel` 的越界死循环 |
| `patches/0005-admonition-support.patch` | 无标题的 `!!! note` 只用类型名作为标题，正文完整保留 |
| `patches/remark-details-admonitions.patch` | 给 `remark-details` 加回 `!!!` 语法支持（作用于 `node_modules`，不是上游源码树） |

## 构建

```sh
nix build .#print          # -> result/pstrode.pdf
nix run .#print -- out.pdf # 复制到指定路径
```

## 与上游同步

```sh
nix flake update oi-wiki-export
nix build .#print
```

`patches/0*.patch` 通过 `patch -p1` 应用在 `oi-wiki-export` 的源码树（`oi-wiki-export-typst/`、`remark-typst/`、`remark-snippet/`）上，路径与上游仓库保持一致；`remark-details-admonitions.patch` 则在上游的 `npm install` 之后应用到 `node_modules/remark-details`。如果上游修改了补丁涉及的文件，构建会直接失败并提示需要更新的补丁。

## 设计说明

- **目录双栏**：`#outline` 生成的内容无法跨栏拆分（它是一整块不可拆分的内容），因此模板改为通过 `query(heading)` 收集条目，按层级权重在章节边界处拆成左右两栏。每个条目显式指定行高，否则正文的紧凑行距会让目录条目互相重叠。
- **内部引用页码**：正文之前的封面和目录会重置 `page` 计数器，物理页号与页眉中显示的页码并不一致，引用改用 `counter(page).at(loc)` 取得实际页码。
- **外部链接**：`remark-typst` 原本会为每个外链在章节末尾生成一个二维码 + 链接列表，占位且浪费纸张。现在外链渲染为 `#link(url)[文本]#footnote[#link(url)]`，即正文中保留可点击的链接文本，页脚给出完整 URL。
- **封面日期**：Typst 的 `datetime.today()` 会跟随 `SOURCE_DATE_EPOCH`，而 Nix 默认把它固定为 1980-01-01，封面上就会出现这个日期。`nix/print.nix` 会把它改成 flake 的修订时间戳（`self.lastModified`），这样封面显示的是这一版内容的日期，同一个修订重复构建也得到同样的 PDF。
- **提示框**：mkdocs 的 `!!! note` / `!!! danger` / `??? tip` 需要 `remark-details` 支持。上游在升级到 v5 时只保留了 `???` 语法，这里把 `!` 重新加回，并让无标题的提示框使用「类型名的首字母大写」作为标题、正文完整保留。
- **排除页面**：`PSTRODE_EXPORT_EXCLUDE` 是逗号分隔的、相对于 `docs/` 的路径列表，以 `/` 结尾表示整个目录，例如默认的 `index.md,intro/`。被排除的页面会直接从导航中剪掉，因此变空的章节会一并消失，剩余章节会重新编号（所以 `基本` 是第一章）。
