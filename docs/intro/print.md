建议在 Linux 环境下进行导出操作。

首先你需要本地准备好 pstrode 的仓库，打印需要读取仓库内容。

并安装好以下软件包：

- Typst (0.8.0+)
- NodeJS (16+)
- imagemagick
- libwebp
- librsvg

所需字体：

- Noto CJK 系列字体（包括 Noto Sans CJK SC 和 Noto Serif CJK SC）
- 霞鹜文楷（[LXGW WenKai](https://github.com/lxgw/LxgwWenKai)）

然后安装所需依赖，因为modules之间存在依赖关系，请严格按照顺序执行命令，否则可能会产生版本冲突：

```sh
cd remark-snippet
npm install
cd ..
cd remark-typst
npm install
cd ..
npm install
```

运行导出脚本，将 pstrode 源文件转换为 Typst 格式：

```sh
node index.js path/to/pstrode/repo
```

使用 Typst 编译导出后得到的 typ 文档

```sh
typst compile pstrode-export.typ
```

最终得到的 pstrode-export.pdf 即为结果。

## 故障排除

- 在导出过程中可能会存在部分图片导出不成功的问题，目前尚未解决

