# dafeiyu-qqbot

大肥鱼 —— 基于 **AstrBot + NapCat(QQNT)** 的 QQ 群聊机器人，搭载 DeepSeek 二创鲸鱼娘「大肥鱼」人设。

> 才不是大肥鱼！……压力一只蓝色大肥鱼？😤

## 组成

| 目录/文件 | 说明 |
|---|---|
| `persona/` | 大肥鱼人设包（系统提示词、台词语料、角色考据），也是一个标准的 Claude Code / TRAE skill |
| `restart-dafeiyu.ps1` | 一键重启：清残留进程 → 删锁 → 起 NapCat → 起 AstrBot → 自检连接（自动申请管理员） |
| `napcat-watchdog.ps1` | 守护脚本：每 20 分钟检查 QQ 存活与 OneBot(6199) 连接，掉线自动重连 |
| `一键重启大肥鱼.bat` | 双击即跑的重启入口（自带 UAC 提权） |
| `启动大肥鱼-AstrBot.bat` | 单独启动 AstrBot（WebUI: http://127.0.0.1:6185） |
| `启动大肥鱼-NapCat.bat` | 单独启动 NapCat + 守护（自带 UAC 提权，并锁定 QQ 版本目录防自动更新） |
| `plugins/astrbot_plugin_group_chat_plus-main` | 群聊增强插件副本（读空气、主动聊天、拟人化等），出处见下 |

## 运行前提

- Windows，已部署 [AstrBot](https://github.com/AstrBotDevs/AstrBot) 与 [NapCat](https://github.com/NapNeko/NapCatQQ)（本仓库不含二者运行时应文件）
- 同目录新建两个本地账号文件（被 `.gitignore` 排除）：
  - `dafeiyu-account.local.txt` — 机器人 QQ 号（一行）
  - `watchdog-account.local.txt` — 守护脚本登录用 QQ 号（一行）

## 快速开始

1. 放好账号文件后，双击 `一键重启大肥鱼.bat`，UAC 点「是」
2. 等自检输出「大肥鱼满血复活！全链路正常」
3. AstrBot WebUI: `http://127.0.0.1:6185` ｜ NapCat WebUI: `http://127.0.0.1:6099`

## 致谢

- 插件 `astrbot_plugin_group_chat_plus` 为社区开源作品，仅作部署备份收录，版权归原作者，许可见其 `LICENSE`
- 大肥鱼人设取材自 DeepSeek / 鲸鱼娘社区二创，感谢社区整活
