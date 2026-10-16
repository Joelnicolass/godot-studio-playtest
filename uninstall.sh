#!/usr/bin/env bash
# Quita skills, command y subagente de este módulo. No toca otras piezas en ~/.cursor ni ~/.claude.
#   ./uninstall.sh [--cursor | --claude | --all] [--project | --dest DIR]   (default: --cursor)
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
HARNESS="cursor"
DEST=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) MODE="project"; shift ;;
    --cursor) HARNESS="cursor"; shift ;;
    --claude) HARNESS="claude"; shift ;;
    --all) HARNESS="all"; shift ;;
    --dest)
      MODE="custom"
      DEST="${2:?--dest requiere un directorio}"
      shift 2
      ;;
    *)
      echo "Uso: $0 [--cursor | --claude | --all] [--project | --dest DIR]" >&2
      exit 1
      ;;
  esac
done

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

remove_from_base() {
  local base="$1"
  remove_named "${base}/skills" "${SKILL_NAMES[@]}"
  remove_named "${base}/commands" "${COMMAND_FILES[@]}"
  remove_named "${base}/agents" "${AGENT_FILES[@]}"
}

if [[ "$MODE" == "custom" ]]; then
  parent="$(cd "$(dirname "$DEST")" && pwd)"
  remove_named "$DEST" "${SKILL_NAMES[@]}"
  remove_named "${parent}/commands" "${COMMAND_FILES[@]}"
  remove_named "${parent}/agents" "${AGENT_FILES[@]}"
  exit 0
fi

case "$HARNESS" in
  all) HARNESSES="cursor claude" ;;
  *) HARNESSES="$HARNESS" ;;
esac

for harness in $HARNESSES; do
  case "$MODE" in
    global) remove_from_base "${HOME}/.${harness}" ;;
    project) remove_from_base "$(pwd)/.${harness}" ;;
  esac
done
