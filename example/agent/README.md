# Workspace AgentKit (este proyecto)

No es el addon. El plugin vive en `addons/agent_kit/` y **no** guarda JSON ni helpers de playtest.

- `flows/` — JSON de `--agent=flow`
- `harness/` — GDScript que AgentKit monta **solo** con `--agent=`. Nodo = basename (`hooks.gd` → `hooks`). Sin `class_name`.
- `out/` — PNG del run (Godot ignora la carpeta)
- `run_suite.sh` — corre los casos principales con `--fail-on-error`

**Nada** del agente sale de este directorio: ni escenas de test en `scenes/`, ni scripts junto a los actores. Fixtures de run: `fixtures/`. Contrato: `skills/godot-agent-kit/harness.md`. Antes de archivos nuevos: `PLAYTEST_PLAN` (tree) y OK. `call()` a `_métodos` que el producto ya tiene es válido.

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
