#!/usr/bin/env bash
# task-ledger skill installer for macOS / Linux
#
# Copies the skill to ~/.claude/skills/task-ledger/ and prints the snippet
# the user needs to add to their global CLAUDE.md to make the skill mandatory
# at session start.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_SRC="${SCRIPT_DIR}/skill"
SKILL_DST="${HOME}/.claude/skills/task-ledger"

if [[ ! -d "${SKILL_SRC}" ]]; then
    echo "[ERROR] skill source not found at ${SKILL_SRC}" >&2
    exit 1
fi

echo "Installing task-ledger skill -> ${SKILL_DST}"
mkdir -p "${SKILL_DST}/templates" "${SKILL_DST}/references"
cp "${SKILL_SRC}/SKILL.md" "${SKILL_DST}/SKILL.md"
cp "${SKILL_SRC}/templates/"*.md "${SKILL_DST}/templates/"
cp "${SKILL_SRC}/references/"*.md "${SKILL_DST}/references/"

echo
echo "[OK] skill installed."
echo
echo "==========================================================================="
echo "NEXT STEP: Add the following to ~/.claude/CLAUDE.md to make the skill"
echo "mandatory at every session start:"
echo "==========================================================================="
cat <<'EOF'

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

EOF
echo "==========================================================================="
echo
echo "To initialize the ledger in a project, run inside its root:"
echo "  mkdir -p docs/task-ledger/sessions docs/task-ledger/archive"
echo "  cp ~/.claude/skills/task-ledger/templates/ACTIVE.md docs/task-ledger/"
echo "  cp ~/.claude/skills/task-ledger/templates/session.md \\"
echo "     docs/task-ledger/sessions/\$(date +%Y-%m-%d).md"
