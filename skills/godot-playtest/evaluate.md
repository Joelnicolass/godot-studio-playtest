# Cómo evaluar un playtest

No hace falta OK del usuario. El playtester **se valida solo** y sigue. Si el corte no se puede jugar como un humano, el informe es un bug, no un atajo.

## Límites (los chequeás vos)

Podés crear o editar solo dentro de `res://agent/`:

| Path | Para qué |
|------|----------|
| `flows/*.json` | El flujo |
| `fixtures/` | Escena de corte que **instancea** packed scenes del producto |
| `harness/*.gd` | Preparar la escena si el JSON no alcanza. Sin `class_name` |
| `out/` | PNG del CLI |

No toques reglas de negocio: `scenes/`, `src/`, `resources/`, `RULES.md`, `project.godot`, InputMap, scripts de actores. No agregues una acción al editor para que el flow pase. Al cierre: `git diff --name-only` solo bajo `agent/`.

## 1. Escena del producto o fixture

`inspect --unique` e `info` primero.

- Si la situación del criterio **ya empieza** en la escena del producto, o quien te invocó ya mandó `PLAYTEST_SETUP`, jugá ahí o armá el fixture con **esas** condiciones. No preguntes de nuevo.
- Si el criterio pide un contexto que esa escena no tiene y el pedido no trae las precondiciones, **no inventes el mundo**. Devolvé solo `NEED_SETUP` a quien te llamó (orquestador u humano) y parate. Sin archivos. Plantilla: [plan.md](plan.md).

El fixture, cuando hace falta, instancea packed scenes del producto y deja el **estado inicial**. La interacción la hace el input. Poner el cubo delante de la nave y pulsar `move_left` prueba el esquive. Poner la nave ya adentro del cubo no prueba el choque: coloca el resultado.

`NEED_SETUP` pide solo: packed scenes que ya existen, estado inicial legítimo (posición, `.tres` existente, qué nodos están), acción de InputMap o control, y qué se observa al final. No pidas cómo armar la escena, ni una acción nueva, ni un cambio de reglas. Si la acción no está en el InputMap, es bug: no es un ítem del pedido.

## 2. El humano juega; el harness no empuja

La situación tiene que ocurrir porque el escenario está armado y el jugador actúa.

- Movimiento y acciones de juego: **solo** `press` de una acción que **ya** está en el InputMap del editor (`move_left`, `ui_accept`, …).
- UI: `click` / `type` / `select` en el control que el jugador usaría. No `call("_on_play")` para saltear el botón.
- Si la acción no existe en el InputMap, o el nombre es un keycode (`KEY_A`, `65`): **BUG de producto**. `press` ya falla con `unmapped input`. No inventes teclas. No las agregues al proyecto.

Prohibido en el harness y en el JSON: `global_position`, `velocity`, `translate`, `InputEventKey`, `time_scale` para llegar antes, un `func` que mueva o dispare, un `call` que fuerce el estado para ganar el assert.

`hooks.gd` no es una cocina de helpers. Si el JSON puede `scene` + `press` + `click`, no agregues un método. Un método nuevo solo prepara (por ejemplo esperar a que el árbol exista) y se reutiliza. No uno por flow.

## 3. Informe

Fixture vs main, acciones de InputMap usadas, y si el diff salió de `agent/`. Un `unmapped input` es FAIL del producto, no del flow.
