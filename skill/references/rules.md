# Task Ledger — 详细规则

## 强制规则(违反就破坏机制)

### R1. ACTIVE.md 是唯一来源(Single Source of Truth)

任何"当前在做什么 / 接下来做什么"的信息,**必须**在 ACTIVE.md。
- ❌ 不能散落在 MEMORY、注释、口头共识里
- ❌ 不能在 sessions/{date}.md 里另写一份(那是流水账,不是清单)
- ✅ 用户问"当前任务",答案就在 ACTIVE.md 里

### R2. 状态变化立即更新(Immediate Update)

不是定时(如"每天总结"),而是**事件驱动**:
- 完成 commit 的 milestone → 立即 update
- 用户拍板新决策 → 立即 update
- 任务挂起 / 取消 → 立即 update
- 新议题出现 → 立即 update

**不要等 session 结束**(会忘)。

### R3. session 文件按日期分(One File per Date)

- 文件名: `sessions/2026-04-27.md`
- 一天可能有多个 session(中断 / 重启),**合并到同一文件**,不要拆 `2026-04-27-am.md` `2026-04-27-pm.md`
- 跨天的工作 → 在新一天的 sessions 文件里 reference 前一天

### R4. archive 只增不删

完成的工程归档:
- 文件名: `archive/{YYYY-MM}-{project-slug}.md`(如 `2026-04-asset-scanner-proactive.md`)
- 内容: 工程目标 / 决策史 / 关键 commits / 学到的经验
- **永不删除**(后续相关工程的参考)

---

## 模板填写指南

### ACTIVE.md 每个任务项的标准结构

```markdown
- [ ] **任务标题** — 进度 X%(可选)
  - 计划文档: `docs/...`(必填,接班 Claude 一秒能跳到)
  - 工作文档: `docs/...`(可选,如果有具体实施文件)
  - 当前状态: 一句话描述(如"等用户拍板 Q1+Q2"、"已写 prompt v2,待跑端到端")
  - 下一步: 一句话(如"建 ACTIVE.md 模板"、"跑 prisma db push")
  - 预计: ~X 天 / X 小时(可选)
  - 关联 commits: `abc1234`, `def5678`(已完成的 milestones)
```

### sessions/{date}.md 每个事件的标准结构

```markdown
## 主要事件

### 14:30 用户提出 X 思路
- 上下文: 为什么提
- 用户原话: "..."
- Claude 评估: 关系是 [正交/覆盖/依赖]
- 决策: [a/b/c],原因

### 15:00 启动 Y 工作
- 创建文件: ...
- commit: ...
```

时间戳精确到分钟,方便追溯。

---

## 特殊场景

### S1. 紧急切换:用户中途扔进新议题

1. 当前任务 → 移到 "🟡 进行中" 但加 "(暂停)"
2. 新议题 → 加到 "🔴 决策待用户拍板"
3. 写到 sessions/{今天}.md
4. 等用户决策后再 update

### S2. compact 前的 checklist

如果你预感即将 compact / context 满:

1. ✅ ACTIVE.md 反映了当前真实状态吗?
2. ✅ sessions/{今天}.md 写了今天的关键决策吗?
3. ✅ 用户拍板的新约定有没有进 ACTIVE.md "决策待用户拍板" 已答?
4. ✅ 当前进行中的任务"下一步"字段是不是接班 Claude 能直接执行的?

任一答 No → 立即补全。

### S3. session 结束的 checklist

1. ✅ 把 "✅ 本会话已完成" 的项 → archive
2. ✅ ACTIVE.md 的剩下 4 个 section 是否都是 "未来要继续"
3. ✅ sessions/{今天}.md 写完总结(产出 + 遗留)
4. ✅ 跟用户确认"还有别的吗?"

### S4. 新 session(包括 compact 后)的开场

1. 读 ACTIVE.md(全文)
2. 读 sessions/{今天}.md(如有)
3. 读最近 1-2 个 sessions/(获取最近上下文)
4. 看 "🟡 进行中" 的任务的"工作文档"是否需要打开
5. 用 SKILL.md 的开场白模板报告状态
6. 等用户确认后再开始工作

---

## 与现有机制的关系

### 跟 MEMORY 系统
- MEMORY 是 Claude 的私人长期记忆(用户偏好 / 跨项目知识)
- task-ledger 是项目级、显式、永久的任务索引
- **互补**:MEMORY 记 "用户喜欢中文沟通",task-ledger 记 "今天要改 propDesigner"

### 跟 session-handover/
- 现有 `docs/session-handover/{date}-session-handover.md` 是手工的 session 总结
- task-ledger 的 sessions/ 是同样的事,但**强制规范** + **跟 ACTIVE.md 配套**
- **建议**:逐步迁移 session-handover → task-ledger/sessions/(不强制立即,新建的统一进 task-ledger)

### 跟 planning-with-files
- planning-with-files 是单工程的 task_plan.md / findings.md / progress.md
- task-ledger 是项目级总账,**包含**所有工程的索引
- ACTIVE.md 的任务项里的"工作文档"字段可以指向 planning-with-files 里的文件

### 跟 git commit
- commit 跟踪 "改了什么"
- ACTIVE.md 跟踪 "在做什么 / 还要做什么"
- 两者**互补**:ACTIVE.md 的任务项里 "关联 commits" 字段连接两者

---

## FAQ

### Q: ACTIVE.md 会不会越来越长?

A: 不会。完成的项立即移到 archive,ACTIVE.md 永远只有"未来"。
   如果 ACTIVE.md > 100 行 → 你没及时归档,用 §S3 checklist 整理。

### Q: 如果一个任务跨多天,sessions/ 里要重复写吗?

A: 不重复。每天的 sessions/ 只写**当天发生的**(进展 / 卡点 / 决策)。
   任务的"全貌"在 ACTIVE.md 单一来源。

### Q: 用户没启用 skill 也行吗?

A: 用户可以不启用(本 skill 是工具,不是强制)。但启用了会显著减少"Claude 又忘了"的痛苦。

### Q: 为什么不用 TodoWrite tool?

A: TodoWrite 是 session 内临时,会话结束就丢。task-ledger 是物理文件,跨 session 持久化。
   两者可共存:TodoWrite 用于会话内细颗粒任务,task-ledger 用于跨 session 主线任务。
