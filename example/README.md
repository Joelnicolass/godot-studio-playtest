# Example — AgentKit

Proyecto Godot 4.7 **mínimo** para probar el módulo: un boot con `%Title`, `%PlaySolo`, `%Status` y `%AfterPlay`.

El plugin ya está en `addons/agent_kit/` (copia de la fuente del repo). El workspace del flow es `agent/`.

## Correr el smoke

Desde la raíz de **este** repo (o con path absoluto a `example/`):

```bash
example/addons/agent_kit/cli.sh example flow --flow=boot_smoke.json --fail-on-error
GODOT="$HOME/Downloads/Godot-7.app/Contents/MacOS/Godot" \
  example/addons/agent_kit/cli.sh example flow --flow=call_private_harness.json --fail-on-error
```

`GODOT=` si el binario no está en PATH / Applications / Downloads.

Capture/flow **sin** `--headless` (hace falta ventana para píxeles).

## Qué hay

| Path | Rol |
|------|-----|
| `scenes/ui/boot.tscn` | Main scene. Unique names para el flow |
| `agent/flows/boot_smoke.json` | Click `%PlaySolo`, assert `%AfterPlay` |
| `agent/flows/call_private_harness.json` | Harness `call("_on_play")` — `_` no es privado de runtime |
| `agent/flows/call_private_json.json` | Step JSON `call` al mismo `_on_play` |
| `agent/harness/hooks.gd` | Helper de playtest; llama métodos que el boot **ya** tiene |
| `agent/out/` | PNG del run (Godot ignora la carpeta) |
| `.cursor/rules/agent-kit-workspace.mdc` | No contaminar producto |

Habilitá el plugin **AgentKit** si lo abrís en el editor. En `project.godot` ya figura el autoload.
