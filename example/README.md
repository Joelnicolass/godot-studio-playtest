# Example — AgentKit

Proyecto Godot 4.7 para probar el módulo: boot 2D → carrera 3D tipo Star Fox (cubos placeholder). Unique names: `%PlaySolo`, `%Ship`, `%ObstacleOnRail`, `%CrashBanner`, `%HpLabel`.

El plugin ya está en `addons/agent_kit/` (copia de la fuente del repo). El workspace del flow es `agent/`.

La primera vez (clone fresco), importá para registrar `class_name`:

```bash
GODOT="$HOME/Downloads/Godot-7.app/Contents/MacOS/Godot" \
  "$GODOT" --headless --path example --import --quit
```

`.godot/global_script_class_cache.cfg` va en git para que el CLI no falle al cargar `run.tscn`.

## Correr la suite

Desde la raíz de **este** repo:

```bash
GODOT="$HOME/Downloads/Godot-7.app/Contents/MacOS/Godot" example/agent/run_suite.sh
```

Casos: boot listo, entrar a la carrera, choque en el rail, esquivar a la izquierda, pasar por encima, chocar el cubo lateral, y `call("_on_play")` (harness y JSON). Detalle: [`agent/README.md`](agent/README.md).

`GODOT=` si el binario no está en PATH / Applications / Downloads.

Capture/flow **sin** `--headless` (hace falta ventana para píxeles).

F5 → **Jugar**: la nave avanza sola y choca el cubo del centro (`%ObstacleOnRail`). WASD/flechas desvían.

## Qué hay

| Path | Rol |
|------|-----|
| `scenes/ui/boot.tscn` | Main scene. **Jugar** entra a la carrera |
| `scenes/world/run.tscn` | Rail 3D, cubos, HUD |
| `agent/flows/` | Suite F1: boot, run, choque, dodge, fly-over, `call` |
| `agent/run_suite.sh` | Corre todos los flows con `--fail-on-error` |
| `agent/harness/hooks.gd` | Helper de playtest; llama métodos que el boot **ya** tiene |
| `agent/out/` | PNG del run (Godot ignora la carpeta) |
| `.cursor/rules/agent-kit-workspace.mdc` | No contaminar producto |

Habilitá el plugin **AgentKit** si lo abrís en el editor. En `project.godot` ya figura el autoload.
