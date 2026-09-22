# Godot studio playtest

Playtest de **Godot 4** para agentes en Cursor: capturar el juego de verdad, hacer clicks como un jugador, y no contaminar `src/`.

Repo: https://github.com/Joelnicolass/godot-studio-playtest

El título vive en **otro** proyecto. Este repo instala el plugin, las skills, el command y el subagente.

## Mapa

Mapa del trabajo de un slice: https://joelnicolass.github.io/godot-studio-playtest/

Fuente: [`docs/architecture.json`](docs/architecture.json).

## Qué problema resuelve

Un agente que “prueba” el juego suele:

1. Tirar `godot -s /tmp/capture.gd` y romper autoloads (`class_name` se compila **antes**).
2. Inventar un PNG o un árbol de nodos de memoria.
3. Meter `agent_setup()`, una escena `test_*.tscn` o spawn en el glue de producto.

Acá el contrato es el contrario: el agente habla con Godot por CLI, el flow es JSON, y los helpers viven en `res://agent/`.

## Qué es cada pieza

Cursor distingue **skill** (procedimiento que el agente carga), **command** (prompt que invocás con `/`) y **subagente** (rol aislado, otro contexto). Este repo usa las tres, más un plugin Godot.

| Pieza | Path | Rol |
|-------|------|-----|
| Plugin Godot | `addons/agent_kit/` | Autoload + `cli.sh`: capture, flow, inspect, fetch, diff. Cero gameplay. |
| Skill `godot-agent-kit` | `skills/godot-agent-kit/` | Cómo hablar con el CLI y dónde va el harness. |
| Skill `godot-playtest` | `skills/godot-playtest/` | Cómo ejercer un slice. No espera OK. Solo escribe en `res://agent/`. |
| Command `/agent-kit` | `commands/agent-kit.md` | Atajo humano: captura / flow / inspect ya. |
| Subagente `studio-playtester` | `agents/studio-playtester.md` | Corre el binario y devuelve PASS/FAIL. No toca reglas de negocio. |
| Workspace | `res://agent/` en **tu** juego | `flows/`, `harness/`, `fixtures/`, `out/`. Lo crea el instalador. **Cero** archivos de playtest fuera. |
| Editor experimental | `experimental/agent-flow-editor/` | Cables → el mismo JSON. No entra en `./install.sh`. |

El trabajo de ese slice está en [Mapa](#mapa).

## Flujo de playtest

Quien llama (el tech lead u otro agente, o un humano) entrega el slice y los criterios. El playtester mira el juego, escribe la partida en `res://agent/` y la corre. El informe vuelve con PASS o FAIL.

```mermaid
sequenceDiagram
  participant C as Quien llama
  participant P as studio-playtester
  participant A as res://agent
  participant G as Godot
  C->>P: Criterios del slice
  P->>G: inspect --unique e info
  G-->>P: %nombres e InputMap
  P->>A: flow JSON y fixture de estado inicial
  P->>G: cli.sh flow --fail-on-error
  Note over G: press de la acción mapeada
  G-->>A: PNG en out/
  G-->>P: AGENT_OK o AGENT_FAIL
  P-->>C: Informe PASS / FAIL
```

El fixture, cuando hace falta, deja el estado inicial con packed scenes del producto. `press` manda un `InputEventAction` de una acción que ya está en el InputMap: `_unhandled_input` con `is_action_pressed` es el camino del juego. Un keycode que no está en el mapa es un bug del producto.

Si falta el estado inicial, el playtester devuelve `NEED_SETUP` y quien llama responde con `PLAYTEST_SETUP`. Si un `class_name` no está en el cache, importa una vez; si el error vuelve, devuelve `CACHE_STALE`.

Reglas cortas:

1. Ejercé **todos** los criterios del slice, no una muestra.
2. No esperes permiso. Si falta el contexto, `NEED_SETUP` y pará. El árbol va en el informe cuando ya podés jugar.
3. Fixture en `res://agent/fixtures/` solo para el estado inicial que el setup nombra. La escena del producto cuando el criterio ya empieza ahí.
4. Solo acciones ya mapeadas en el editor, o click/type del control. Sin keycodes. Sin `func` que mueva o fuerce el estado.
5. Cero archivos fuera de `res://agent/`. Cero cambios a InputMap, resources o scripts de juego.
6. `capture` / `flow` necesitan **ventana**. `--fail-on-error` tumba el run si Godot logueó ERROR.
7. Un `SCRIPT ERROR` o `unmapped input` es FAIL. `Could not find type` de un `class_name` que ya existe: un `--import` y se reintenta el flow. Si vuelve, `CACHE_STALE` a quien llamó.

## Instalar Cursor

```bash
./install.sh              # ~/.cursor/skills, commands, agents
./install.sh --project    # ./.cursor/ del cwd
```

`npx skills add Joelnicolass/godot-studio-playtest -g -a cursor -y` copia **solo** `skills/`. Command, subagente y addon van con `./install.sh`.

Chat **nuevo** en Cursor después de instalar.

## Instalar el plugin en un juego

```bash
./install.sh --addon /path/to/godot-project
```

Habilitá **AgentKit**. En `project.godot` (CI):

```
AgentKit="*res://addons/agent_kit/agent_kit.gd"
```

```bash
addons/agent_kit/cli.sh /ABS/GODOT_ROOT inspect --unique
addons/agent_kit/cli.sh /ABS/GODOT_ROOT flow --flow=boot_smoke.json --fail-on-error
```

`GODOT=` si el binario no está en PATH. Sin `--agent=`, F5 no cambia.

## Demo

[`example/`](example/README.md) es el slice de prueba (boot → carrera). `example/addons/agent_kit` es un enlace a `addons/agent_kit/`: una sola fuente.

```bash
example/addons/agent_kit/cli.sh example flow --flow=boot_smoke.json --fail-on-error
example/addons/agent_kit/cli.sh example flow --flow=crash_side.json --fail-on-error
```

## Editor de flow (opcional)

```bash
cd experimental/agent-flow-editor
pnpm install
pnpm dev
```

http://localhost:5173 — mismo JSON que `--agent=flow`. Zoom con rueda o `+` / `−` en la barra. Detalle: [`experimental/agent-flow-editor/README.md`](experimental/agent-flow-editor/README.md).

## Layout

```
addons/agent_kit/                 # plugin Godot (fuente)
skills/godot-agent-kit/           # CLI + harness
skills/godot-playtest/            # playtest humano + plan.md + evaluate.md
agents/studio-playtester.md
commands/agent-kit.md
example/                          # demo Godot 4.7
experimental/agent-flow-editor/
docs/                             # mapa Archify → GitHub Pages
install.sh
```

## Qué no es

No es un runner de tests unitarios. No es un MCP. No es un motor de juego. No juzga look.
