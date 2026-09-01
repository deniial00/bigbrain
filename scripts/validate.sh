#!/usr/bin/env bash
set -euo pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$repo_root"

mapfile -t discovered < <(find .opencode/skills -mindepth 2 -maxdepth 2 -type f -name SKILL.md | sort)
[[ ${#discovered[@]} -eq 44 ]]

for skill_file in "${discovered[@]}"; do
  skill_dir=$(basename -- "$(dirname -- "$skill_file")")
  grep -q "^name: $skill_dir$" "$skill_file"
  grep -q '^description:' "$skill_file"
  [[ -f $(dirname -- "$skill_file")/.bigbrain-managed ]]
  ! grep -q '^disable-model-invocation:' "$skill_file"
done

grep -q '^name: bigbrain$' .opencode/skills/bigbrain/SKILL.md
grep -q '^compatibility: opencode$' .opencode/skills/bigbrain/SKILL.md

playbook_count=$(find .opencode/skills/bigbrain/playbooks -maxdepth 1 -type f -name '*.md' | wc -l | tr -d ' ')
principle_count=$(find .opencode/skills -mindepth 1 -maxdepth 1 -type d -name 'principle-*' | wc -l | tr -d ' ')
skill_count=${#discovered[@]}
[[ $playbook_count == 23 ]]
[[ $principle_count == 21 ]]

grep -q '^mode: subagent$' .opencode/agents/bigbrain.md
grep -q '^mode: subagent$' .opencode/agents/comment-sicko.md
grep -q '^  edit: deny$' .opencode/agents/comment-sicko.md

test_root=$(mktemp -d)
trap 'rm -rf -- "$test_root"' EXIT

mkdir -p "$test_root/global/opencode/skills/user-skill"
printf '%s\n' user-owned > "$test_root/global/opencode/skills/user-skill/SKILL.md"
mkdir -p "$test_root/global/opencode/skills/bigbrain/references/skills/stale"
touch "$test_root/global/opencode/skills/bigbrain/.bigbrain-managed"
XDG_CONFIG_HOME=$test_root/global ./install.sh --global --copy >/dev/null
[[ -f $test_root/global/opencode/skills/bigbrain/SKILL.md ]]
[[ -f $test_root/global/opencode/skills/how/SKILL.md ]]
[[ ! -e $test_root/global/opencode/skills/bigbrain/references/skills ]]
[[ $(find "$test_root/global/opencode/skills" -mindepth 2 -maxdepth 2 -type f -name .bigbrain-managed | wc -l | tr -d ' ') == 44 ]]
[[ -f $test_root/global/opencode/agents/bigbrain.md ]]
[[ $(grep -c 'bigbrain:start' "$test_root/global/opencode/AGENTS.md") == 1 ]]

XDG_CONFIG_HOME=$test_root/global ./install.sh --global --copy >/dev/null
[[ $(grep -c 'bigbrain:start' "$test_root/global/opencode/AGENTS.md") == 1 ]]

XDG_CONFIG_HOME=$test_root/global ./install.sh --global --uninstall >/dev/null
[[ ! -e $test_root/global/opencode/skills/bigbrain ]]
[[ ! -e $test_root/global/opencode/skills/how ]]
[[ -f $test_root/global/opencode/skills/user-skill/SKILL.md ]]
[[ $(grep -c 'bigbrain:start' "$test_root/global/opencode/AGENTS.md" || true) == 0 ]]

XDG_CONFIG_HOME=$test_root/linked ./install.sh --global >/dev/null
[[ -L $test_root/linked/opencode/skills/bigbrain ]]
[[ -L $test_root/linked/opencode/skills/how ]]
XDG_CONFIG_HOME=$test_root/linked ./install.sh --global --uninstall >/dev/null
[[ ! -e $test_root/linked/opencode/skills/bigbrain ]]
[[ ! -e $test_root/linked/opencode/skills/how ]]

mkdir -p "$test_root/project"
./install.sh --project "$test_root/project" >/dev/null
[[ -f $test_root/project/.opencode/skills/bigbrain/SKILL.md ]]
[[ -f $test_root/project/.opencode/skills/how/SKILL.md ]]
[[ $(find "$test_root/project/.opencode/skills" -mindepth 2 -maxdepth 2 -type f -name .bigbrain-managed | wc -l | tr -d ' ') == 44 ]]
[[ $(grep -c 'bigbrain:start' "$test_root/project/AGENTS.md") == 1 ]]

mkdir -p "$test_root/collision/.opencode/skills/how"
printf '%s\n' user-owned > "$test_root/collision/.opencode/skills/how/SKILL.md"
if ./install.sh --project "$test_root/collision" >/dev/null 2>&1; then
  printf 'Expected unmanaged skill collision to fail.\n' >&2
  exit 1
fi
grep -q '^user-owned$' "$test_root/collision/.opencode/skills/how/SKILL.md"
[[ ! -e $test_root/collision/.opencode/skills/architect ]]

printf 'Validated %s native skills, %s principles, and %s playbooks.\n' "$skill_count" "$principle_count" "$playbook_count"
