# task-ledger — Claude Code Skill

A persistent task-ledger skill for [Claude Code](https://github.com/anthropics/claude-code) that survives session boundaries, compactions, and branch switches.

[中文](#中文) | [English](#english)

---

## English

### What it solves

Claude Code's session boundaries (new session, `/compact` summarization, branch switch) cause **context loss**. The next Claude has no idea what you were just working on, what's blocked on a decision, or what the canonical next step is — and re-explaining costs ~5 minutes per resume.

`task-ledger` solves this with **two physical markdown files** that the next Claude reads at session start:

```
docs/task-ledger/
├── ACTIVE.md           ⭐ Single source of truth - "what now / next"
├── sessions/
│   └── YYYY-MM-DD.md   Daily journal - "what happened today, why"
└── archive/
    └── *.md            Completed work, kept for reference
```

The next Claude reads `ACTIVE.md` + `sessions/{today}.md` and reports the state in 3 seconds:

> "I see the task ledger: 2 in progress, 3 pending, 1 awaiting your decision.
>  Last session (2026-04-27) finished Plan 07 Tasks 1-6.
>  Next up per ACTIVE.md: T7 FastAPI scaffold. Correct?"

### Five required sections in `ACTIVE.md`

| Section | When to add | When to remove |
|---|---|---|
| 🟡 In progress | Task started | Task done → ✅ |
| 🔵 Pending | User signed off, not yet started | When picked up → 🟡 |
| ⏸️ Paused / On hold | Explicitly paused with reason | When resumed → 🟡 |
| 🔴 Awaiting user decision | Blocked on user input | When user answered → 🔵 or 🟡 |
| ✅ Done this session | Task completed today | End of session → archive/ |

Each task carries: checkbox · short name · key doc paths · progress · next action.

### Install

#### macOS / Linux

```bash
git clone https://github.com/<your-username>/task-ledger-skill.git
cd task-ledger-skill
./install.sh
```

#### Windows (PowerShell)

```powershell
git clone https://github.com/<your-username>/task-ledger-skill.git
cd task-ledger-skill
.\install.ps1
```

The installer copies the skill into `~/.claude/skills/task-ledger/` and prints the snippet to add to your global `CLAUDE.md`.

### Add to your global `CLAUDE.md`

Append this section to `~/.claude/CLAUDE.md` (Windows: `C:\Users\<you>\.claude\CLAUDE.md`):

```markdown
## ⚠️ Task ledger rule (mandatory)

Every new session / post-compact / post-branch-switch — first thing:

1. Check whether the project root has `docs/task-ledger/ACTIVE.md`
2. If yes → **invoke `task-ledger` skill** to read `ACTIVE.md` + `sessions/{today}.md`
   and use the SKILL.md opening template to report state.
3. If no, and the project is in active multi-session development →
   suggest initializing the ledger.

State changes (commit lands / user decides / task pauses / new question raised)
→ **immediately** update ACTIVE.md, not at session end.
```

### Manual init in a new project

When you're starting a project that needs the ledger:

```bash
mkdir -p docs/task-ledger/sessions docs/task-ledger/archive
cp ~/.claude/skills/task-ledger/templates/ACTIVE.md docs/task-ledger/ACTIVE.md
cp ~/.claude/skills/task-ledger/templates/session.md "docs/task-ledger/sessions/$(date +%Y-%m-%d).md"
```

Then ask Claude: "Initialize the task ledger" — it will read the templates and populate.

### Anti-patterns to avoid

- ❌ Copying the task list into `sessions/` files (sessions are journals; lists belong in ACTIVE.md only)
- ❌ Duplicating ACTIVE.md to a new file each day (ACTIVE.md is the single source of truth)
- ❌ Updating the ledger only at session end (state can change minute-by-minute; update immediately)
- ❌ Deleting the archive (completed work is reference for future projects)
- ❌ Using ACTIVE.md as a substitute for git commit messages (ACTIVE = "what we're doing", commit = "what code changed")

### License

MIT.

---

## 中文

### 解决什么问题

Claude Code 的 session 边界（新 session、`/compact` 压缩、切换分支）会**导致 context 丢失**。下一个 Claude 不知道你刚在做什么、有什么决策待你拍板、下一步该做什么——每次重新对齐要花 ~5 分钟。

`task-ledger` 用**两份物理 markdown 文件**解决：

```
docs/task-ledger/
├── ACTIVE.md           ⭐ 唯一活动任务索引（永远反映"现在/未来"）
├── sessions/
│   └── YYYY-MM-DD.md   每日流水账（发生了什么、为什么这样决策）
└── archive/
    └── *.md            完成的工程归档，保留作未来参考
```

下一个 Claude 读 `ACTIVE.md` + `sessions/{今天}.md`，3 秒内报告状态：

> "我看到任务总账：2 项进行中、3 项待做、1 项待决策。
>  上次 session（2026-04-27）完成了 Plan 07 Tasks 1-6。
>  根据 ACTIVE.md，接下来要做 T7 FastAPI scaffold。是吗？"

### `ACTIVE.md` 的 5 个状态分类

| 分类 | 何时加入 | 何时移出 |
|---|---|---|
| 🟡 进行中 | 任务被启动 | 任务完成 → ✅ |
| 🔵 待做 | 用户拍板要做、还没开 | 启动后 → 🟡 |
| ⏸️ 暂停 / 挂起 | 显式挂起、原因明确 | 恢复 → 🟡 |
| 🔴 决策待用户拍板 | 阻塞中等用户回答 | 用户回了 → 🔵 或 🟡 |
| ✅ 本会话已完成 | 当天完成的项 | session 结束 → archive |

每项任务包含：`[ ]`/`[x]` checkbox · 任务名 · 关键文档路径 · 进度 · 下一步动作。

### 安装

#### macOS / Linux

```bash
git clone https://github.com/<your-username>/task-ledger-skill.git
cd task-ledger-skill
./install.sh
```

#### Windows (PowerShell)

```powershell
git clone https://github.com/<your-username>/task-ledger-skill.git
cd task-ledger-skill
.\install.ps1
```

安装脚本会把 skill 复制到 `~/.claude/skills/task-ledger/` 并打印需要加到全局 `CLAUDE.md` 的代码片段。

### 加到全局 `CLAUDE.md`

把这段加到 `~/.claude/CLAUDE.md`（Windows: `C:\Users\<你>\.claude\CLAUDE.md`）：

```markdown
## ⚠️ 每次 session 开始 — 任务总账规则（强制）

每次新 session 启动 / compact 后 / 切换分支后，进入项目工作前第一件事：

1. 检查项目根是否有 `docs/task-ledger/ACTIVE.md`
2. 如有 → **必须调用 `task-ledger` skill**，读 `ACTIVE.md` + `sessions/{今天}.md`，
   用 SKILL.md 的开场白模板报告当前状态
3. 如无、且项目在做多 session 长期开发 → 主动建议用户初始化

任务状态变化时（完成 commit / 用户拍板 / 任务挂起 / 新议题）→ **立即** update ACTIVE.md。
```

### 在新项目里手工初始化

```bash
mkdir -p docs/task-ledger/sessions docs/task-ledger/archive
cp ~/.claude/skills/task-ledger/templates/ACTIVE.md docs/task-ledger/ACTIVE.md
cp ~/.claude/skills/task-ledger/templates/session.md "docs/task-ledger/sessions/$(date +%Y-%m-%d).md"
```

然后告诉 Claude："初始化 task ledger"——它会读模板填充内容。

### 反模式（避免）

- ❌ 把任务清单复制到 `sessions/` 文件（sessions 是流水账，清单只在 ACTIVE.md 一份）
- ❌ 每天复制 ACTIVE.md 到新文件（ACTIVE.md 是唯一真源，只 update、不 duplicate）
- ❌ 等 session 结束才一次性更新（状态变化时立即 update）
- ❌ 删除 archive（完成的工程归档保留）
- ❌ 用 ACTIVE.md 替代 git commit message（ACTIVE = "在做什么"，commit = "改了什么"）

### 许可证

MIT。
