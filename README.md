## **pstrode**

这是我的个人的收集和整理 XCPC 算法模板的项目，欢迎参考。

本项目基于 [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/) 生成静态站点，使用 [uv](https://github.com/astral-sh/uv) 管理 Python 依赖，并使用 Nix flake 提供开发环境、构建与部署流程。

欢迎提交 Pull Request 或通过 Issue 反馈问题。

## 使用 Nix

仓库提供了 flake，包含静态站点与打印 PDF 的构建，以及开发环境与部署脚本。需要启用 flakes：

```bash
nix develop                 # 进入开发环境（Typst、Node.js、mkdocs 等）
nix build .#site            # 构建静态站点 -> result/
nix build .#print           # 构建打印用 PDF -> result/pstrode.pdf
nix run .#serve             # 本地预览站点
nix run .#print -- out.pdf  # 把 PDF 复制到 out.pdf
nix run .#deploy -- result  # 部署静态站点到 Cloudflare Pages
```

## 许可与免责

- 代码部分（`docs/` 以外的所有内容）使用 [MIT 许可证](LICENSE) 开源。
- 文档与模板内容（`docs/` 目录下）以 [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) 许可分享。

本项目部分内容收集自网络，若涉及侵权或未注明原作者，请通过 Issue 告知，我会及时处理。

## 打印此项目

本项目的打印功能基于 [OI-Wiki-export](https://github.com/OI-wiki/OI-Wiki-export) ，通过 flake input 跟踪上游更新，pstrode 自己的定制放在 [`print/`](print/) 目录中。

```bash
nix build .#print
```

生成的 PDF 位于 `result/pstrode.pdf` 。详见 [打印文档](docs/intro/print.md) 。

## 基于此创建您自己的项目

### 在 GitHub 上 fork 项目

你可以 fork 此项目。

### 本地部署

#### 使用 Nix

```bash
nix develop
mkdocs serve
```

#### 使用 uv

本项目使用 [uv](https://github.com/astral-sh/uv) 管理 Python 依赖，请先安装 uv。

clone 本项目或者你的 fork 到本地。并且进入项目目录。

安装依赖：

```bash
uv sync
```

本地预览：

```bash
uv run mkdocs serve
```

你可以修改 `docs/` 中的文件来编辑内容。通过编辑 `mkdocs.yml` 来编辑站点配置。

### 部署到 Cloudflare Pages

可以通过 Nix 构建并直接部署：

```bash
nix build .#site
nix run .#deploy -- result
```

需要设置 `CLOUDFLARE_API_TOKEN` 与 `CLOUDFLARE_ACCOUNT_ID` ，项目名默认是 `pstrode` ，可用 `CLOUDFLARE_PAGES_PROJECT` 覆盖。

也可以继续使用 Cloudflare Pages 的 Git 集成：

导出依赖至 `requirements.txt`

```bash
uv export --no-hashes -o requirements.txt
```

将仓库 push 到 GitHub 上。随后
进入 Cloudflare dashboard ，前往 Workers & Pages 页面。

选择 Create application

选择 Pages 标签页

选择 Import an existing Git repository 。

选择你刚刚 fork 的 GitHub 仓库。

在 Set up builds and deployments 部分，填入如下信息：

| Configuration option | Value |
| - | - |
| Production branch | main |
| Build command | mkdocs build |
| Build directory |	site |

前往 Environment variables (advanced) > Add variable ，并且添加环境变量 PYTHON_VERSION ，设置其值为 3.12

确认后，你将成功在 Cloudflare Pages 上部署站点。
