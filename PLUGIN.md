# 飞书 CLI 插件

插件直接加载 [上游技能](./skills/)，通过运行环境中的 `lark-cli` 操作飞书或 Lark。

## CLI 安装与授权

首次使用时，在运行 Claude Code 或 Codex 的环境安装 CLI 并授权。已有可用 CLI 和登录配置时，运行 `lark-cli auth status` 确认状态即可。

```bash
npm install -g @larksuite/cli
lark-cli config init
lark-cli auth login
lark-cli auth status
```

## Claude Code

```bash
claude plugin marketplace add faketrader/lark-cli
claude plugin install lark-cli@faketrader-lark-cli
```

拉取更新时运行 `claude plugin marketplace update faketrader-lark-cli`，然后运行 `claude plugin update lark-cli@faketrader-lark-cli`。

## Codex

```bash
codex plugin marketplace add faketrader/lark-cli
codex plugin add lark-cli@faketrader-lark-cli
```

桌面端也可在插件目录中选择 `faketrader-lark-cli` 来源并安装 **Lark CLI**。运行 `codex plugin marketplace upgrade faketrader-lark-cli` 拉取更新。

## 上游同步

[Sync upstream](./.github/workflows/sync-upstream.yml) 每周五 12:34 UTC 将 `larksuite/cli` 的 `main` 合并到此 fork 的 `main`。源码和技能随合并更新，`.github/workflows/` 由 fork 自行管理。发生其他路径的合并冲突时，工作流会列出冲突文件并停止。解决冲突后可在 GitHub Actions 中手动运行。

## English

Install the `lark-cli` plugin through the marketplace for Claude Code or Codex. The plugin uses the upstream skills and requires an installed, authorised Lark CLI. The fork merges upstream changes every Friday at 12:34 UTC and keeps its own GitHub Actions workflows.
