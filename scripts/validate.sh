#!/usr/bin/env bash
set -euo pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$repo_root"

mapfile -t discovered < <(find .opencode/skills -mindepth 2 -maxdepth 2 -type f -name SKILL.md | sort)
[[ ${#discovered[@]} -eq 1 ]]
[[ ${discovered[0]} == .opencode/skills/bigbrain/SKILL.md ]]
grep -q '^name: bigbrain$' .opencode/skills/bigbrain/SKILL.md
grep -q '^compatibility: opencode$' .opencode/skills/bigbrain/SKILL.md

playbook_count=$(find .opencode/skills/bigbrain/references/skills/bigbrain-core/playbooks -maxdepth 1 -type f -name '*.md' | wc -l | tr -d ' ')
principle_count=$(find .opencode/skills/bigbrain/references/skills -maxdepth 1 -type d -name 'principle-*' | wc -l | tr -d ' ')
skill_count=$(find .opencode/skills/bigbrain/references/skills -mindepth 2 -maxdepth 2 -type f -name SKILL.md | wc -l | tr -d ' ')
[[ $playbook_count == 23 ]]
[[ $principle_count == 21 ]]
[[ $skill_count == 44 ]]

grep -q '^mode: subagent$' .opencode/agents/bigbrain.md
grep -q '^mode: subagent$' .opencode/agents/comment-sicko.md
grep -q '^  edit: deny$' .opencode/agents/comment-sicko.md

test_root=$(mktemp -d)
trap 'rm -rf -- "$test_root"' EXIT

XDG_CONFIG_HOME=$test_root/global ./install.sh --global --copy >/dev/null
[[ -f $test_root/global/opencode/skills/bigbrain/SKILL.md ]]
[[ -f $test_root/global/opencode/agents/bigbrain.md ]]
[[ $(grep -c 'bigbrain:start' "$test_root/global/opencode/AGENTS.md") == 1 ]]

XDG_CONFIG_HOME=$test_root/global ./install.sh --global --copy >/dev/null
[[ $(grep -c 'bigbrain:start' "$test_root/global/opencode/AGENTS.md") == 1 ]]

XDG_CONFIG_HOME=$test_root/global ./install.sh --global --uninstall >/dev/null
[[ ! -e $test_root/global/opencode/skills/bigbrain ]]
[[ $(grep -c 'bigbrain:start' "$test_root/global/opencode/AGENTS.md" || true) == 0 ]]

mkdir -p "$test_root/project"
./install.sh --project "$test_root/project" >/dev/null
[[ -f $test_root/project/.opencode/skills/bigbrain/SKILL.md ]]
[[ $(grep -c 'bigbrain:start' "$test_root/project/AGENTS.md") == 1 ]]

printf 'Validated one discoverable skill, %s workflows, %s principles, and %s playbooks.\n' "$skill_count" "$principle_count" "$playbook_count"
