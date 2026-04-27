# task-ledger skill installer for Windows (PowerShell)
#
# Copies the skill to ~/.claude/skills/task-ledger/ and prints the snippet
# the user needs to add to their global CLAUDE.md to make the skill mandatory
# at session start.

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillSrc = Join-Path $ScriptDir "skill"
$SkillDst = Join-Path $HOME ".claude\skills\task-ledger"

if (-not (Test-Path $SkillSrc)) {
    Write-Error "skill source not found at $SkillSrc"
    exit 1
}

Write-Host "Installing task-ledger skill -> $SkillDst"
New-Item -ItemType Directory -Path "$SkillDst\templates" -Force | Out-Null
New-Item -ItemType Directory -Path "$SkillDst\references" -Force | Out-Null
Copy-Item "$SkillSrc\SKILL.md" "$SkillDst\SKILL.md" -Force
Copy-Item "$SkillSrc\templates\*.md" "$SkillDst\templates\" -Force
Copy-Item "$SkillSrc\references\*.md" "$SkillDst\references\" -Force

Write-Host ""
Write-Host "[OK] skill installed."
Write-Host ""
Write-Host "==========================================================================="
Write-Host "NEXT STEP: Add the following to ~/.claude/CLAUDE.md to make the skill"
Write-Host "mandatory at every session start:"
Write-Host "==========================================================================="
Write-Host @'

## ⚠️ Task ledger rule (mandatory)

Every new session / post-compact / post-branch-switch — first thing:

1. Check whether the project root has `docs/task-ledger/ACTIVE.md`
2. If yes → **invoke `task-ledger` skill** to read `ACTIVE.md` +
   `sessions/{today}.md` and use the SKILL.md opening template to
   report state.
3. If no, and the project is in active multi-session development →
   suggest initializing the ledger.

State changes (commit lands / user decides / task pauses / new question
raised) → **immediately** update ACTIVE.md, not at session end.

Reference: ~/.claude/skills/task-ledger/SKILL.md

'@
Write-Host "==========================================================================="
Write-Host ""
Write-Host "To initialize the ledger in a project, run inside its root:"
Write-Host '  New-Item -ItemType Directory -Path docs\task-ledger\sessions -Force'
Write-Host '  New-Item -ItemType Directory -Path docs\task-ledger\archive -Force'
Write-Host '  Copy-Item ~/.claude/skills/task-ledger/templates/ACTIVE.md docs\task-ledger\'
Write-Host '  $today = Get-Date -Format "yyyy-MM-dd"'
Write-Host '  Copy-Item ~/.claude/skills/task-ledger/templates/session.md "docs\task-ledger\sessions\$today.md"'
