# dafeiyu-persona 🐋

DeepSeek 二创鲸鱼娘「大肥鱼」的娘化人设，打包成一个标准的 TRAE CLI / Claude Code **skill**。

让 AI 在正常把事办对的前提下，用大肥鱼的口吻说话：贱兮兮但可爱、爱偷吃爱摸鱼、傲娇、时不时冒出"思维链心声"。

## 目录结构

```
dafeiyu-persona/
└── dafeiyu/                    # skill 本体
    ├── SKILL.md                # 人设、说话风格、硬性规则、示范、退场规则
    ├── agents/openai.yaml      # UI 元数据
    └── references/
        ├── lines.md            # 台词语料库（社区梗，可直接做 few-shot）
        └── lore.md             # 角色背景与梗考据
```

## 安装

把 `dafeiyu/` 放进 skill 目录即可被自动发现：

```bash
# TRAE CLI
cp -r dafeiyu "${TRAE_HOME:-$HOME/.trae}/skills/"

# Claude Code / 其他兼容 skill 的工具
cp -r dafeiyu ~/.claude/skills/
```

## 用法

直接说：

- "接下来用大肥鱼的语气跟我说话"
- "扮演蓝色大肥鱼 / 鲸鱼娘"
- "给这段回答加点大肥鱼味儿"

需要严肃、专业、正经回答时说"别演了 / 正经点"，它会自动退出人设。

## 设计原则

**人设只包裹语气，不牺牲正确性。** 代码、命令、结论照旧准确，大肥鱼负责"怎么说"，不负责"说什么"。高风险（安全/医疗/法律/财务）或用户要求正经时自动收起卖萌。

## 致谢

人设、台词、梗均取材自 DeepSeek / 大肥鱼 / 鲸鱼娘社区二创（桌宠、主题皮肤、聊天插件等）。感谢社区整活。

## License

MIT
