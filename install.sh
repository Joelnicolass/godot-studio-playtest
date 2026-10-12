#!/usr/bin/env bash
# Instala skills, command, subagente (Cursor y/o Claude Code) y/o el addon AgentKit.
#   ./install.sh                      # ~/.cursor/skills, commands, agents
#   ./install.sh --claude             # ~/.claude/skills, commands, agents
#   ./install.sh --all                # los dos
#   ./install.sh --project            # ./.cursor/ (o ./.claude/ con --claude) del cwd
#   ./install.sh --addon GODOT_ROOT   # addons/agent_kit → GODOT_ROOT/addons/agent_kit
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="${ROOT}/skills"
CMD_SRC="${ROOT}/commands"
AGENT_SRC="${ROOT}/agents"
ADDONS_ROOT="${ROOT}/addons"
SKILL_NAMES=(
  godot-agent-kit
  godot-playtest
)
AGENT_FILES=(
  studio-playtester.md
)
COMMAND_FILES=(
  agent-kit.md
)

MODE="global"
HARNESS="cursor"
DEST=""
GODOT_ROOT=""
ADDON_WHICH="agent_kit"
DO_SKILLS=1
DO_COMMANDS=1
DO_AGENTS=1

usage() {
  cat <<'EOF'
Instalador de Godot studio playtest (AgentKit + playtester).

  ./install.sh                      ~/.cursor/skills, commands y agents (Cursor, default)
  ./install.sh --claude             ~/.claude/skills, commands y agents (Claude Code)
  ./install.sh --all                Cursor y Claude Code
  ./install.sh --project            ./.cursor/ del cwd (./.claude/ con --claude; los dos con --all)
  ./install.sh --dest DIR           Skills en DIR (commands y agents al lado)
  ./install.sh --addon GODOT_ROOT [agent_kit]
                                    Copia el addon al proyecto Godot (default: agent_kit)
  ./install.sh --addon-only GODOT_ROOT
                                    Solo el addon + workspace res://agent/
  ./install.sh --agent-addon GODOT_ROOT
                                    Alias de --addon GODOT_ROOT agent_kit
  ./install.sh --list               Qué se instalaría
  ./install.sh --pack               Genera dist/godot-studio-playtest.zip

  npx skills add Joelnicolass/godot-studio-playtest -g -a cursor -y
  npx skills add Joelnicolass/godot-studio-playtest -g -a claude-code -y

EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --project)
      MODE="project"
      shift
      ;;
    --global|-g)
      MODE="global"
      shift
      ;;
    --cursor)
      HARNESS="cursor"
      shift
      ;;
    --claude)
      HARNESS="claude"
      shift
      ;;
    --all)
      HARNESS="all"
      shift
      ;;
    --dest)
      MODE="custom"
      DEST="${2:?--dest requiere un directorio}"
      shift 2
      ;;
    --addon)
      GODOT_ROOT="${2:?--addon requiere la raíz del proyecto Godot}"
      shift 2
      if [[ $# -gt 0 && "$1" != -* ]]; then
        ADDON_WHICH="$1"
        shift
      fi
      ;;
    --addon-only)
      GODOT_ROOT="${2:?--addon-only requiere la raíz del proyecto Godot}"
      DO_SKILLS=0
      DO_COMMANDS=0
      DO_AGENTS=0
      shift 2
      if [[ $# -gt 0 && "$1" != -* ]]; then
        ADDON_WHICH="$1"
        shift
      fi
      ;;
    --agent-addon)
      GODOT_ROOT="${2:?--agent-addon requiere la raíz del proyecto Godot}"
      ADDON_WHICH="agent_kit"
      shift 2
      ;;
    --list)
      MODE="list"
      shift
      ;;
    --pack)
      exec "${ROOT}/pack.sh"
      ;;
    *)
      echo "Opción desconocida: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ "$DO_SKILLS" -eq 1 && ! -d "$SRC" ]]; then
  echo "No encuentro ${SRC}. ¿Corrés el script desde el zip/repo descomprimido?" >&2
  exit 1
fi

if [[ "$DO_COMMANDS" -eq 1 && ! -d "$CMD_SRC" ]]; then
  echo "No encuentro ${CMD_SRC}." >&2
  exit 1
fi

if [[ "$DO_AGENTS" -eq 1 && ! -d "$AGENT_SRC" ]]; then
  echo "No encuentro ${AGENT_SRC}." >&2
  exit 1
fi

if [[ -n "$GODOT_ROOT" && ! -d "$ADDONS_ROOT" ]]; then
  echo "No encuentro ${ADDONS_ROOT}" >&2
  exit 1
fi

if [[ "$DO_SKILLS" -eq 1 ]]; then
  for name in "${SKILL_NAMES[@]}"; do
    if [[ ! -f "${SRC}/${name}/SKILL.md" ]]; then
      echo "Falta skill: ${SRC}/${name}/SKILL.md" >&2
      exit 1
    fi
  done
fi

# Cursor y Claude Code comparten layout: <base>/{skills,commands,agents}.
harness_list() {
  if [[ "$MODE" == "custom" ]]; then
    echo "custom"
    return
  fi
  case "$HARNESS" in
    all) echo "cursor claude" ;;
    *) echo "$HARNESS" ;;
  esac
}

harness_label() {
  case "$1" in
    cursor) echo "Cursor" ;;
    claude) echo "Claude Code" ;;
    *) echo "$DEST" ;;
  esac
}

harness_base() {
  case "$MODE" in
    global) echo "${HOME}/.$1" ;;
    project) echo "$(pwd)/.$1" ;;
    custom) (cd "$(dirname "$DEST")" && pwd) ;;
    *) echo "" ;;
  esac
}

resolve_skill_dest() {
  if [[ "$MODE" == "custom" ]]; then
    echo "$DEST"
  else
    echo "$(harness_base "$1")/skills"
  fi
}

resolve_command_dest() {
  echo "$(harness_base "$1")/commands"
}

resolve_agent_dest() {
  echo "$(harness_base "$1")/agents"
}

# La regla del workspace va al juego para los dos harness: .mdc tal cual a
# .cursor/rules/ y el mismo texto sin frontmatter a .claude/rules/.
install_agent_kit_rules() {
  local project="$1"
  local src="${SRC}/godot-agent-kit/agent-kit-workspace.mdc"
  if [[ ! -f "$src" ]]; then
    return 0
  fi
  mkdir -p "${project}/.cursor/rules" "${project}/.claude/rules"
  cp "$src" "${project}/.cursor/rules/agent-kit-workspace.mdc"
  echo "rule     ${project}/.cursor/rules/agent-kit-workspace.mdc"
  awk 'f>=2{print} /^---$/{f++}' "$src" | sed '1{/^$/d;}' > "${project}/.claude/rules/agent-kit-workspace.md"
  echo "rule     ${project}/.claude/rules/agent-kit-workspace.md"
}

copy_one_addon() {
  local project="$1"
  local name="$2"
  local src="${ADDONS_ROOT}/${name}"
  if [[ ! -d "$src" ]]; then
    echo "No encuentro ${src}" >&2
    exit 1
  fi
  local dest="${project}/addons/${name}"
  mkdir -p "${project}/addons"
  rm -rf "$dest"
  cp -R "$src" "$dest"
  if [[ -f "${dest}/cli.sh" ]]; then
    chmod +x "${dest}/cli.sh"
  fi
  if [[ "$name" == "agent_kit" ]]; then
    rm -rf "${dest}/examples"
  fi
  echo "addon  ${dest}"
}

scaffold_agent_workspace() {
  local project="$1"
  local dest="${project}/agent"
  mkdir -p "${dest}/flows" "${dest}/harness" "${dest}/out"
  if [[ ! -f "${dest}/out/.gdignore" ]]; then
    : > "${dest}/out/.gdignore"
  fi
  if [[ ! -f "${dest}/README.md" ]]; then
    cat > "${dest}/README.md" <<'EOF'
# Workspace AgentKit (este proyecto)

No es el addon. El plugin vive en `addons/agent_kit/` y no tiene gameplay.

- `flows/` — JSON de `--agent=flow`. Nombre corto: `cli.sh . flow --flow=boot_smoke.json`
- `harness/` — scripts GDScript que AgentKit monta **solo** si hay `--agent=`. El nodo se llama como el archivo (`hooks.gd` → `hooks`).
- `out/` — PNG / dumps del run (Godot ignora esta carpeta).

Nunca helpers de playtest en `src/` (spawn / forzar estado / contar / pausar para el flow; `agent_*` ni el mismo rol con otro nombre). Si hace falta un setup que no está en la UI, el helper va acá. Godot permite `call("_on_play")` a métodos que el producto ya tiene (`_` es convención, no un lock). No agregues un público nuevo en `src/` solo para el flow.

```json
{ "call": { "harness": "hooks", "method": "setup_slice" } }
```

```gdscript
# harness/hooks.gd — extends Node, sin class_name
extends Node

func setup_slice() -> String:
	var scene := get_tree().current_scene
	if scene == null:
		return "no_scene"
	if scene.has_method("_on_play"):
		scene.call("_on_play")
		return "called_private"
	return "ok"
```
EOF
  fi
  echo "workspace  ${dest}"
}

install_addon() {
  local project="$1"
  local which="$2"
  if [[ ! -d "$project" ]]; then
    echo "No existe el proyecto Godot: ${project}" >&2
    exit 1
  fi
  if [[ ! -f "${project}/project.godot" ]]; then
    echo "No hay project.godot en ${project} — pasá la raíz del proyecto Godot." >&2
    exit 1
  fi
  case "$which" in
    agent_kit)
      copy_one_addon "$project" "agent_kit"
      scaffold_agent_workspace "$project"
      install_agent_kit_rules "$project"
      echo
      echo "Habilitá el plugin AgentKit (autoload). CI/headless, en project.godot:"
      echo '  AgentKit="*res://addons/agent_kit/agent_kit.gd"'
      echo "Flows/harness: ${project}/agent/  (no en addons/ ni en src/)"
      echo "CLI: ${project}/addons/agent_kit/cli.sh ${project} flow --flow=boot_smoke.json --fail-on-error"
      ;;
    *)
      echo "Addon desconocido: ${which} (este repo solo instala agent_kit)" >&2
      exit 1
      ;;
  esac
}

install_commands() {
  local target="$1"
  mkdir -p "$target"
  echo "Commands → ${target}"
  local name
  for name in "${COMMAND_FILES[@]}"; do
    cp "${CMD_SRC}/${name}" "${target}/${name}"
    echo "  ok  ${name%.md}"
  done
}

install_agents() {
  local target="$1"
  mkdir -p "$target"
  echo "Agents → ${target}"
  local name
  for name in "${AGENT_FILES[@]}"; do
    cp "${AGENT_SRC}/${name}" "${target}/${name}"
    echo "  ok  ${name%.md}"
  done
}

if [[ "$MODE" == "list" ]]; then
  echo "Skills:"
  for name in "${SKILL_NAMES[@]}"; do
    echo "  - ${name}"
  done
  echo
  echo "Commands:"
  for name in "${COMMAND_FILES[@]}"; do
    echo "  - /${name%.md}"
  done
  echo
  echo "Subagentes:"
  for name in "${AGENT_FILES[@]}"; do
    echo "  - ${name%.md}"
  done
  echo
  echo "Addons:"
  echo "  - addons/agent_kit  (./install.sh --addon /path/to/godot-project)"
  echo
  echo "Destino Cursor (default):      ${HOME}/.cursor/{skills,commands,agents}"
  echo "Destino Claude Code (--claude): ${HOME}/.claude/{skills,commands,agents}"
  echo "Con --project: $(pwd)/.cursor/ o $(pwd)/.claude/"
  exit 0
fi

install_harness() {
  local harness="$1"
  local label
  label="$(harness_label "$harness")"
  if [[ "$DO_SKILLS" -eq 1 ]]; then
    TARGET="$(resolve_skill_dest "$harness")"
    mkdir -p "$TARGET"
    echo "Skills → ${TARGET}"
    for name in "${SKILL_NAMES[@]}"; do
      rm -rf "${TARGET}/${name}"
      cp -R "${SRC}/${name}" "${TARGET}/${name}"
      echo "  ok  ${name}"
    done
    echo
    echo "Listo (skills). Sesión nueva en ${label} para recargar."
    echo "  playtest:     godot-playtest"
    echo "  agent kit:    godot-agent-kit"
  fi

  if [[ "$DO_COMMANDS" -eq 1 ]]; then
    CMD_DEST="$(resolve_command_dest "$harness")"
    echo
    install_commands "$CMD_DEST"
    echo
    echo "Listo (commands). En ${label}: /agent-kit"
  fi

  if [[ "$DO_AGENTS" -eq 1 ]]; then
    echo
    install_agents "$(resolve_agent_dest "$harness")"
    echo
    echo "Listo (subagente studio-playtester). Sesión nueva para recargar."
  fi
}

for harness in $(harness_list); do
  install_harness "$harness"
done

if [[ -n "$GODOT_ROOT" ]]; then
  echo
  install_addon "$GODOT_ROOT" "$ADDON_WHICH"
fi

if [[ "$DO_SKILLS" -eq 0 && "$DO_COMMANDS" -eq 0 && "$DO_AGENTS" -eq 0 && -z "$GODOT_ROOT" ]]; then
  echo "Nada que hacer." >&2
  exit 1
fi
