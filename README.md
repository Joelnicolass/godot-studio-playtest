# Godot studio playtest

Playtest de **Godot 4** para agentes en Cursor: capturar el juego de verdad, hacer clicks como un jugador, y no contaminar `src/`.

Repo: https://github.com/Joelnicolass/godot-studio-playtest

El título vive en **otro** proyecto. Este repo instala el plugin, las skills, el command y el subagente.

## Mapa

Mapa interactivo del playtest: https://joelnicolass.github.io/godot-studio-playtest/

Fuente: [`docs/architecture.json`](docs/architecture.json).

## Qué problema resuelve

Un agente que “prueba” el juego suele:

1. Tirar `godot -s /tmp/capture.gd` y romper autoloads (`class_name` se compila **antes**).
2. Inventar un PNG o un árbol de nodos de memoria.
3. Meter `agent_setup()`, una escena `test_*.tscn` o spawn en el glue de producto.

Acá el contrato es el contrario: el agente habla con Godot por CLI, el flow es JSON, y los helpers viven en `res://agent/`.

```mermaid
flowchart TB
  subgraph before [Sin AgentKit]
    a1["godot -s /tmp/*.gd"]
    a2[PNG inventado]
    a3["test.tscn / agent_* en scenes/"]
    a1 --> fail[Autoloads rotos / evidencia falsa]
    a2 --> fail
    a3 --> fail
  end

  subgraph after [Con este módulo]
    b1[addons/agent_kit CLI]
    b2["res://agent/flows JSON"]
    b3["res://agent/harness"]
    b1 --> ok["AGENT_OK / AGENT_FAIL"]
    b2 --> ok
    b3 --> ok
  end
```

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

El grafo de esas piezas está en [Mapa](#mapa).

## Flujo de playtest

El playtest arranca con la orden de probar el slice. No pide permiso. Si la escena del producto no trae el contexto y quien llamó no mandó las condiciones, devuelve `NEED_SETUP` y espera `PLAYTEST_SETUP`. Quien llama es otro agente o un humano.

```mermaid
flowchart TD
  slice[Slice a probar] --> seen{¿La situación ya está en la escena o vino PLAYTEST_SETUP?}
  seen -->|no| ask[NEED_SETUP al caller]
  ask --> setup[PLAYTEST_SETUP]
  seen -->|sí| cut[Escena del producto o fixture]
  setup --> cut
  cut --> input{¿La acción está en el InputMap o hay un control?}
  input -->|no| bug[BUG de producto: input no mapeado]
  input -->|sí| run["press / click como el jugador"]
  run --> report[PASS / FAIL + PNG]
```

Reglas cortas:

1. Ejercé **todos** los criterios del slice, no una muestra.
2. No esperes permiso. Si falta el contexto, `NEED_SETUP` y pará. El árbol va en el informe cuando ya podés jugar.
3. Fixture en `res://agent/fixtures/` solo para el estado inicial que el setup nombra. La escena del producto cuando el criterio ya empieza ahí.
4. Solo acciones ya mapeadas en el editor, o click/type del control. Sin keycodes. Sin `func` que mueva o fuerce el estado.
5. Cero archivos fuera de `res://agent/`. Cero cambios a InputMap, resources o scripts de juego.
6. `capture` / `flow` necesitan **ventana**. `--fail-on-error` tumba el run si Godot logueó ERROR.
7. Un `SCRIPT ERROR` o `unmapped input` es FAIL.

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
example/addons/agent_kit/cli.sh example flow --flow=call_private_harness.json --fail-on-error
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
