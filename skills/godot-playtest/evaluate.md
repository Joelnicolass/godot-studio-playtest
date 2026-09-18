# Cómo evaluar un playtest

El playtester **elige el corte** (fixture, input, harness) para que el criterio falle a la vista si el bug sigue. No para ahorrar clics al agente.

## 1. Escena de prueba aislada, no la main

Para una feature concreta, **no** arranques la escena principal (boot, hub, run completo) si el criterio no es ese flujo.

Armá un `.tscn` en `res://agent/fixtures/` que instancee packed scenes **del producto** (`ship.tscn`, un obstáculo, el HUD del slice). `%UniqueName` para asserts. El JSON pone `"scene": "res://agent/fixtures/…"`.

La main scene queda para criterios de boot / navegación entre pantallas.

Nunca esa fixture en `scenes/` ni `tests/`. No dupliques reglas de partida en el fixture: reutilizá `.tres` del producto o el packed scene.

En el `PLAYTEST_PLAN`, justificá: *por qué esta fixture y no la main*.

## 2. Reusar hooks; no un archivo-cocina

`res://agent/harness/hooks.gd` es un **puente chico**, no un dump de `setup_flow_12`.

Orden:

1. ¿El flow JSON ya puede `press` / `click` / `scene`? No agregues un método.
2. ¿Ya hay un hook que hace eso (cambiar a fixture, `call` a un `_on_play` existente)? **Reusalo.**
3. ¿Hace falta setup? Un método **genérico** (`goto_fixture(path)`, `call_existing(node, method)`), no un gemelo por cada JSON.
4. Otro `.gd` en `harness/` solo si el dominio es otro (p. ej. UI vs rail) y `hooks.gd` se iría de unas pocas funciones.

Prohibido: un `func` nuevo por flow, o un `hooks.gd` de cientos de líneas de one-shots.

## 3. Input del jugador, no teletransporte

La acción bajo prueba se ejerce como el jugador: `press` del **InputMap** (`move_left`, `ui_accept`, …), `click` / `try_click` en botones, `type` en campos.

Más certero que `global_position =`, `velocity =`, `translate`, `move_and_slide` o `call("steer")` inventado en el harness.

El harness **no** mueve al actor para “ganar” el assert. Setup de escena = fixture + `%` + packed scenes. Si el jugador no puede llegar ahí con input, el criterio es de producto (reportá), no un warp.

`call()` a un `_método` que el juego **ya** tiene vale para *disparar lo que un botón dispararía* (`_on_play`), no para forzar física.
