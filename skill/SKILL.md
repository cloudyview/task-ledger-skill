---
name: task-ledger
description: "维护项目任务总账(ACTIVE.md + sessions/{date}.md),解决 session/compact 后 Claude 忘记当前任务和未完成工作的问题。session 开始时必读总账,任务状态变化时立即更新。"
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
---

# Task Ledger — 项目任务总账规范

## 设计目的

Claude Code session 边界 / compact 操作 / 新 session 启动会**导致 context 丢失**。
本 skill 通过**物理落盘的双层结构**解决:
- `ACTIVE.md` — 唯一的"现在/未来"任务索引(永远反映当前状态)
- `sessions/{YYYY-MM-DD}.md` — 当天会话的"流水账"(发生了什么)

物理文件不会被 compact 压缩,接班 Claude 必读这两个文件即可对齐当前状态。

---

## 文件结构(在当前项目根)

```
docs/task-ledger/
├── README.md           ← 总账规则说明 + 接班指引
├── ACTIVE.md           ← ⭐ 唯一活动任务索引(常更新)
├── sessions/
│   └── YYYY-MM-DD.md   ← 每个会话一份(可多个,按日期)
└── archive/
    └── *.md            ← 完成的工程归档
```

**模板**: 见本 skill 的 `templates/` 子目录。

---

## 何时使用本 skill

### 1. Session 开始(必)

无论是新 session、compact 后、还是切换分支后开始工作:

1. 读 `docs/task-ledger/ACTIVE.md`(如果存在)
2. 读 `docs/task-ledger/sessions/{今天}.md`(如果存在)
3. **主动告诉用户**: "我看到当前是 X 状态(进行中:N 项 / 待做:N 项 / 待决策:N 项),今天接下来要做的是 Y。是吗?"

如果文件不存在 → 用 `templates/` 初始化。

### 2. 任务状态变化(必)

不是每天定时,而是**每次状态真正变化时**立刻更新 `ACTIVE.md`:
- 完成一个 commit 的 milestone → `[ ]` → `[x]` + 移到"本会话已完成"
- 新决策被用户拍板 → 加到"待做"
- 任务被挂起 → 移到"暂停 / 挂起"
- 用户提出新议题 → 加到"决策待用户拍板"

### 3. Session 结束 / compact 前(必)

1. 写完今天的 `sessions/{今天}.md`(如还没写)
2. 把 ACTIVE.md 的"本会话已完成"列表移到 archive(避免 ACTIVE.md 越来越长)
3. 清理 ACTIVE.md(只保留进行中/待做/挂起/待拍板)

### 4. 用户主动 invoke(可选)

用户输入 `/task-ledger` 或 `用 task-ledger skill` 时,执行 §1 行为(读总账并报告状态)。

---

## ACTIVE.md 规范

5 个状态分类,**严格使用这 5 类**(不要新增/合并):

| Section | Emoji | 含义 | 何时移入 |
|---|---|---|---|
| **🟡 进行中** | 已启动但未完成的任务 | 任务被启动 |
| **🔵 待做** | 已规划、按顺序待启动 | 用户拍板要做 |
| **⏸️ 暂停 / 挂起** | 暂停的工作(原因明确) | 显式挂起 |
| **🔴 决策待用户拍板** | 阻塞中,等用户回答 | 用户没回 Q |
| **✅ 本会话已完成** | 当天完成的项 | 任务完成,session 结束时移 archive |

每项任务必须含:
- `[ ]` / `[x]` checkbox
- 任务名称(简洁描述)
- 关键文档路径(让接班 Claude 一秒打开)
- 进度(如果适用)
- 下一步动作

**模板**: `.claude/skills/task-ledger/templates/ACTIVE.md`

---

## sessions/{date}.md 规范

记录"发生了什么 + 决策为什么这样",**不重复 ACTIVE.md 的清单**。

包含 4 个 section:
1. **主线**: 今天的核心目标
2. **主要事件**(时间顺序): 关键节点 + 决策
3. **决策点**: 用户拍板的事 + 选项的理由
4. **产出**: 新增/修改的关键文件 + commits

**模板**: `.claude/skills/task-ledger/templates/session.md`

---

## 反模式(避免)

❌ **不要把任务清单复制到 sessions/ 文件**
   sessions/ 是流水账,清单只在 ACTIVE.md 一份

❌ **不要每天复制 ACTIVE.md 到新文件**
   ACTIVE.md 永远是唯一来源,只 update,不 duplicate

❌ **不要等 session 结束才一次性更新**
   状态变化时立即更新,避免遗忘

❌ **不要把 archive 的内容删掉**
   完成的工程归档保留,作为后续工程的参考资料

❌ **不要用 ACTIVE.md 替代 git commit message**
   ACTIVE.md 跟踪 "在做什么",commit 跟踪 "改了什么",两者互补

---

## 详细规则

参见 `references/rules.md`(高级:强制规则、模板填写指南、特殊场景处理)

---

## 接班 Claude 的开场白模板

读完 ACTIVE.md + sessions/{今天}.md 后,**第一句话必须**是:

> "我看到任务总账,当前 [X] 项进行中、[Y] 项待做、[Z] 项待决策。
>  上次 session(YYYY-MM-DD) 完成了 [关键产出]。
>  根据 ACTIVE.md,接下来要做的是 [next step]。
>  是吗?有什么变化要先告诉我吗?"

让用户**3 秒内**确认 Claude 跟得上,不需要再花 5 分钟"重新对齐"。
