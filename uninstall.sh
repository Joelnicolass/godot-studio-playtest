#!/usr/bin/env bash
# Quita skills, command y subagente de este módulo. No toca otras piezas en ~/.cursor.
set -euo pipefail

SKILL_NAMES=(
  godot-agent-kit
  godot-playtest
)
COMMAND_FILES=(
  agent-kit.md
)
AGENT_FILES=(
  studio-playtester.md
)

MODE="global"
DEST=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) MODE="project"; shift ;;
    --dest)
      MODE="custom"
      DEST="${2:?--dest requiere un directorio}"
      shift 2
      ;;
    *)
      echo "Uso: $0 [--project | --dest DIR]" >&2
      exit 1
      ;;
  esac
done

case "$MODE" in
  global)
    SKILL_TARGET="${HOME}/.cursor/skills"
    CMD_TARGET="${HOME}/.cursor/commands"
    AGENT_TARGET="${HOME}/.cursor/agents"
    ;;
  project)
    SKILL_TARGET="$(pwd)/.cursor/skills"
    CMD_TARGET="$(pwd)/.cursor/commands"
    AGENT_TARGET="$(pwd)/.cursor/agents"
    ;;
  custom)
    SKILL_TARGET="$DEST"
    parent="$(cd "$(dirname "$DEST")" && pwd)"
    CMD_TARGET="${parent}/commands"
    AGENT_TARGET="${parent}/agents"
    ;;
esac

remove_named() {
  local target="$1"
  shift
  if [[ ! -d "$target" ]]; then
    echo "ausente  ${target}"
    return
  fi
  local name
  for name in "$@"; do
    if [[ -e "${target}/${name}" ]]; then
      rm -rf "${target}/${name}"
      echo "quitado  ${name}"
    else
      echo "ausente  ${name}"
    fi
  done
}

remove_named "$SKILL_TARGET" "${SKILL_NAMES[@]}"
remove_named "$CMD_TARGET" "${COMMAND_FILES[@]}"
remove_named "$AGENT_TARGET" "${AGENT_FILES[@]}"
