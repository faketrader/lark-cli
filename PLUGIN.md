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

## Magpie

在 **资源库 → Claude 插件** 中搜索并安装 `faketrader/lark-cli`。已安装时，点开插件卡片并选择 **更新**。

## 上游同步

[Sync upstream](./.github/workflows/sync-upstream.yml) 每周五 12:34 UTC 合并上游的[最新正式 Release](https://github.com/larksuite/cli/releases/latest)。插件技能取自同一个发布标签，插件版本使用标签中的版本号，例如 `v1.0.100` 对应 `1.0.100`。`.github/workflows/` 由 fork 自行管理。其他路径发生合并冲突时，工作流会列出文件并停止。

## English

Install the `lark-cli` plugin through Claude Code, Codex or Magpie. The plugin requires an installed, authorised Lark CLI. Every Friday at 12:34 UTC, the fork syncs its plugin version and skills with the latest official release.
