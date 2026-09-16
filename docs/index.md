## 欢迎来到 **pstrode**

这是我的个人的收集和整理 XCPC 算法模板的项目，欢迎参考。

本项目的 C++ 代码，除非另有说明，否则建议使用 **C++17 或更高版本** 的标准。

!!! danger
    本项目模板代码若无特殊说明，统一使用 0 索引下标，左开右闭表示区间，注意保持统一或者进行转换，避免造成未定义行为。

本项目基于 [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/) 生成静态站点，使用 [uv](https://github.com/astral-sh/uv) 管理 Python 依赖，并使用 Nix flake 提供开发环境与构建、部署流程。

欢迎提交 Pull Request 或通过 Issue 反馈问题。

## 许可与免责

- 代码部分（`docs/` 以外的所有内容）使用 MIT 许可证 开源。
- 文档与模板内容（`docs/` 目录下）以 [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) 许可分享。

本项目部分内容收集自网络，若涉及侵权或未注明原作者，请通过 Issue 告知，我会及时处理。

## 项目仓库

[https://github.com/pstron/pstrode](https://github.com/pstron/pstrode)

若你需要打印、基于此创建类似项目等，请查阅仓库文档。

## 打印此项目

本项目的打印功能基于 [OI-Wiki-export](https://github.com/OI-wiki/OI-Wiki-export) ，将整个站点导出为印刷质量的 PDF。

仓库提供了 Nix flake，构建方式：

```sh
nix build .#print
```

生成的 PDF 位于 `result/pstrode.pdf` 。关于打印功能的更多说明，请参阅站点导航中的“打印”页面。

