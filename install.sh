#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf '%s\n' \
    'Usage: ./install.sh [--global | --project PATH] [--copy] [--uninstall]' \
    '' \
    '  --global        Install for every OpenCode project. This is the default.' \
    '  --project PATH  Install only in one repository.' \
    '  --copy          Copy files instead of linking them. Project installs always copy.' \
    '  --uninstall     Remove only files managed by this installer.'
}

script_dir=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
scope=global
project_dir=
copy_files=false
uninstall=false

while (($#)); do
  case "$1" in
    --global)
      scope=global
      ;;
    --project)
      [[ $# -ge 2 ]] || { usage >&2; exit 2; }
      scope=project
      project_dir=$2
      shift
      ;;
    --copy)
      copy_files=true
      ;;
    --uninstall)
      uninstall=true
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown option: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

if [[ $scope == global ]]; then
  config_root=${XDG_CONFIG_HOME:-"$HOME/.config"}/opencode
  instructions_file=$config_root/AGENTS.md
else
  [[ -n $project_dir && -d $project_dir ]] || { printf 'Project directory not found: %s\n' "$project_dir" >&2; exit 2; }
  project_dir=$(CDPATH= cd -- "$project_dir" && pwd)
  config_root=$project_dir/.opencode
  instructions_file=$project_dir/AGENTS.md
  copy_files=true
fi

skills_source=$script_dir/.opencode/skills
agent_source=$script_dir/.opencode/agents
skills_target_root=$config_root/skills
bigbrain_agent_target=$config_root/agents/bigbrain.md
comment_agent_target=$config_root/agents/comment-sicko.md
start_marker='<!-- bigbrain:start -->'
end_marker='<!-- bigbrain:end -->'

remove_bootstrap() {
  local target=$1
  [[ -f $target ]] || return 0
  local temp
  temp=$(mktemp)
  awk -v start="$start_marker" -v end="$end_marker" '
    $0 == start { skip = 1; next }
    $0 == end { skip = 0; next }
    !skip { print }
  ' "$target" > "$temp"
  mv "$temp" "$target"
}

install_bootstrap() {
  local target=$1
  mkdir -p "$(dirname -- "$target")"
  remove_bootstrap "$target"
  [[ ! -s $target ]] || printf '\n' >> "$target"
  printf '%s\n' "$start_marker" >> "$target"
  sed '1d;$d' "$script_dir/bootstrap.md" >> "$target"
  printf '%s\n' "$end_marker" >> "$target"
}

remove_managed_path() {
  local target=$1
  local kind=$2
  [[ -e $target || -L $target ]] || return 0
  if [[ -L $target ]]; then
    if [[ $kind == skill && -f $target/.bigbrain-managed ]]; then
      rm "$target"
      return 0
    fi
    if [[ $kind == agent && -f $target ]] && grep -q 'bigbrain-managed' "$target"; then
      rm "$target"
      return 0
    fi
    printf 'Refusing to remove unmanaged symlink: %s\n' "$target" >&2
    exit 1
  fi
  if [[ $kind == skill && -f $target/.bigbrain-managed ]]; then
    rm -rf -- "$target"
    return 0
  fi
  if [[ $kind == agent && -f $target ]] && grep -q 'bigbrain-managed' "$target"; then
    rm -- "$target"
    return 0
  fi
  printf 'Refusing to remove unmanaged path: %s\n' "$target" >&2
  exit 1
}

check_tree_target() {
  local target=$1
  [[ -e $target || -L $target ]] || return 0
  if [[ $copy_files == true ]]; then
    [[ ! -L $target && -f $target/.bigbrain-managed ]] && return 0
  else
    [[ -L $target && -f $target/.bigbrain-managed ]] && return 0
  fi
  printf 'Refusing to replace unmanaged directory: %s\n' "$target" >&2
  exit 1
}

check_agent_target() {
  local target=$1
  [[ -e $target || -L $target ]] || return 0
  if [[ $copy_files == true ]]; then
    [[ ! -L $target && -f $target ]] && grep -q 'bigbrain-managed' "$target" && return 0
  else
    [[ -L $target && -f $target ]] && grep -q 'bigbrain-managed' "$target" && return 0
  fi
  printf 'Refusing to replace unmanaged agent: %s\n' "$target" >&2
  exit 1
}

install_tree() {
  local source=$1
  local target=$2
  mkdir -p "$(dirname -- "$target")"
  if [[ $copy_files == true ]]; then
    if [[ -e $target && ! -f $target/.bigbrain-managed ]]; then
      printf 'Refusing to replace unmanaged directory: %s\n' "$target" >&2
      exit 1
    fi
    if [[ -e $target ]]; then
      rm -rf -- "$target"
    fi
    mkdir -p "$target"
    cp -R "$source/." "$target/"
  else
    if [[ -e $target && ! -L $target ]]; then
      printf 'Refusing to replace unmanaged directory: %s\n' "$target" >&2
      exit 1
    fi
    ln -sfn "$source" "$target"
  fi
}

install_agent() {
  local source=$1
  local target=$2
  mkdir -p "$(dirname -- "$target")"
  if [[ $copy_files == true ]]; then
    if [[ -f $target ]] && ! grep -q 'bigbrain-managed' "$target"; then
      printf 'Refusing to replace unmanaged agent: %s\n' "$target" >&2
      exit 1
    fi
    cp "$source" "$target"
  else
    if [[ -e $target && ! -L $target ]]; then
      printf 'Refusing to replace unmanaged agent: %s\n' "$target" >&2
      exit 1
    fi
    ln -sfn "$source" "$target"
  fi
}

if [[ $uninstall == true ]]; then
  if [[ -d $skills_target_root ]]; then
    for skill_target in "$skills_target_root"/*; do
      [[ -f $skill_target/.bigbrain-managed ]] || continue
      remove_managed_path "$skill_target" skill
    done
  fi
  remove_managed_path "$bigbrain_agent_target" agent
  remove_managed_path "$comment_agent_target" agent
  remove_bootstrap "$instructions_file"
  printf 'Removed bigbrain from %s\n' "$config_root"
  exit 0
fi

for skill_source in "$skills_source"/*; do
  [[ -d $skill_source ]] || continue
  check_tree_target "$skills_target_root/$(basename -- "$skill_source")"
done
check_agent_target "$bigbrain_agent_target"
check_agent_target "$comment_agent_target"

for skill_source in "$skills_source"/*; do
  [[ -d $skill_source ]] || continue
  install_tree "$skill_source" "$skills_target_root/$(basename -- "$skill_source")"
done
install_agent "$agent_source/bigbrain.md" "$bigbrain_agent_target"
install_agent "$agent_source/comment-sicko.md" "$comment_agent_target"
install_bootstrap "$instructions_file"

printf 'Installed bigbrain in %s\n' "$config_root"
printf 'Restart OpenCode to reload skills, agents, and instructions.\n'
