# Example — AgentKit

Proyecto Godot 4.7 **mínimo** para probar el módulo: un boot con `%Title`, `%PlaySolo`, `%Status` y `%AfterPlay`. Cero MpKit, cero gameplay de título.

El plugin ya está en `addons/agent_kit/` (copia de la fuente del repo). El workspace del flow es `agent/`.

## Correr el smoke

Desde la raíz de **este** repo (o con path absoluto a `example/`):

```bash
example/addons/agent_kit/cli.sh example flow --flow=boot_smoke.json --fail-on-error
```

`GODOT=` si el binario no está en PATH / Applications / Downloads.

Capture/flow **sin** `--headless` (hace falta ventana para píxeles).

## Qué hay

| Path | Rol |
|------|-----|
| `scenes/ui/boot.tscn` | Main scene. Unique names para el flow |
| `agent/flows/boot_smoke.json` | Click `%PlaySolo`, assert `%AfterPlay` |
| `agent/harness/` | Vacío a propósito. Helpers van acá, no en `scenes/` |
| `agent/out/` | PNG del run (Godot ignora la carpeta) |
| `.cursor/rules/agent-kit-workspace.mdc` | No contaminar producto |

Habilitá el plugin **AgentKit** si lo abrís en el editor. En `project.godot` ya figura el autoload.
