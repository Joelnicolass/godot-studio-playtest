# Workspace AgentKit (este proyecto)

No es el addon. El plugin vive en `addons/agent_kit/` y **no** guarda JSON ni helpers de playtest.

- `flows/` — JSON de `--agent=flow`
- `fixtures/` — escenas de corte (instancean packed scenes del producto). No la main salvo boot.
- `harness/` — solo si el JSON no puede preparar la escena. Sin `class_name`. No un `func` que mueva o fuerce el estado.
- `out/` — PNG del run (Godot ignora la carpeta)
- `run_suite.sh` — corre los casos principales con `--fail-on-error`

**Nada** del agente sale de este directorio. No se tocan reglas de negocio ni el InputMap. Si el contexto no está en la escena ni en el pedido, el playtester devuelve `NEED_SETUP` a quien lo llamó. La acción es `press` de una acción ya mapeada, o `click` en el control. Si no hay acción, es un bug. `call("_on_play")` en esta demo solo prueba que `_` no es privado; un playtest de feature no lo usa para jugar.

## Suite F1

| Flow | Caso |
|------|------|
| `boot_ready.json` | Boot: **Jugar** habilitado, `%AfterPlay` oculto |
| `enter_run.json` | **Jugar** entra a la carrera: `%Ship`, cubo del rail, HP 1, sin banner |
| `crash_center.json` | Sin input: choca `%ObstacleOnRail` → **Chocaste**, HP 0 |
| `dodge_left.json` | `move_left` breve: pasa el cubo del centro, sigue HP 1 |
| `fly_over.json` | `move_up` breve: pasa por encima, sigue HP 1 |
| `crash_side.json` | `move_left` largo: choca el cubo lateral → **Chocaste** |
| `call_private_harness.json` | Harness `call("_on_play")` → misma carrera |
| `call_private_json.json` | Step JSON `call` a `_on_play` |

`obstacle_crash.json` es el mismo caso que `crash_center.json`. `boot_smoke.json` es el mismo que `boot_ready.json`.

```bash
GODOT="$HOME/Downloads/Godot-7.app/Contents/MacOS/Godot" example/agent/run_suite.sh
```
