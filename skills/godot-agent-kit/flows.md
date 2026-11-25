# Flows JSON

`--agent=flow --flow=res://agent/flows/boot_smoke.json --out=res://agent/out`

Nombre corto: `--flow=boot_smoke.json` (busca en `res://agent/flows/`).

```json
{
  "scene": "res://scenes/ui/boot.tscn",
  "wait_first": 0.8,
  "steps": [
    { "shot": "01.png" },
    { "click": "%PlaySolo" },
    { "wait": 0.4 },
    { "assert": { "node": "%AfterPlay", "visible": true } },
    { "print": { "node": "%Status", "prop": "text" } }
  ]
}
```

UI que aparece y desaparece:

```json
{
  "repeat": {
    "times": 180,
    "until": { "node": "%AfterPlay", "visible": true },
    "steps": [
      { "try_click": "%PlaySolo" },
      { "wait": 0.2 }
    ]
  }
}
```

`click` manda el puntero al centro del control y solo cuenta si dispara `pressed`. Si no pega, el step falla (`click missed`). `try_click` puede saltar solo dentro de un `repeat` con `until`, mientras el control no está listo. `press` manda un `InputEventAction` de la acción del InputMap (`parse_input_event`) para que `_unhandled_input` / `is_action_pressed` lo reciban, y mantiene el hold con `action_press` en cada frame de física. No manda keycodes. Si la acción no está mapeada, falla con `unmapped input`. `seed` y `time_scale` fallan: no son acciones del jugador. `call` sobre un nodo del producto falla.

Clic en el mundo (una casilla de un tablero, una unidad en 3D), donde no hay un `Control` que nombrar:

```json
{ "click_at": { "x": 640, "y": 360 } }
{ "click_at": { "world": [12.1, 0.4, 7.0], "button": "left" } }
```

`click_at` manda el recorrido de un mouse: `InputEventMouseMotion` hasta el punto, press y release (`Input.parse_input_event`, un frame entre cada uno). Lo reciben la GUI, `_input` y `_unhandled_input`, como un clic real: si un `Control` tapa el punto, lo toma el `Control` y el mundo no se entera. `x`, `y`: píxeles del viewport (el espacio de `event.position`). `world`: un punto 3D que AgentKit proyecta con la `Camera3D` actual del viewport raíz; preferilo a `x`, `y` porque no depende de la resolución ni del tamaño de la ventana. Sacá el punto del juego, no de un PNG: por ejemplo el centro global de una casilla (`board.global_transform * board.cell_to_position(cell)`). Apuntá a la superficie que el juego prueba con el rayo: el plano del tablero, o la cara de arriba si la casilla tiene altura. Un punto más alto que esa superficie cae, siguiendo el rayo, un poco más lejos de la cámara. `button`: `left` (default), `right`, `middle`. Loguea `AGENT_CLICK at=x,y button=… world=…`. Falla sin cámara 3D, con el punto detrás de la cámara o fuera de la pantalla. Sirve dentro de `repeat` (por ejemplo, clic en la casilla hasta que `until` pase). El juego lee el clic de `event.position`; `get_viewport().get_mouse_position()` sigue al mouse real de la ventana.

`scene` vacío en la raíz = main scene. Un step `{ "scene": "res://…" }` cambia de escena. `%Nombre` se resuelve en la escena y, si falta, en hijos. `repeat` corre `steps` hasta `times` o hasta que `until` pase.

Otros steps: `{ "select": { "node": "%Rooms", "index": 0 } }` o `"text"`; `{ "range": { "node": "%Vol", "value": 0.5 } }`; `{ "scroll": { "node": "%List", "vertical": 80 } }`; `{ "drag": { "node": "%Pad", "from_x": 8, "from_y": 8, "to_x": 80, "to_y": 8 } }`; `{ "shot": { "name": "hud.png", "node": "%Status" } }` recorta un Control; `{ "diff": { "a": "01.png", "b": "02.png", "max_percent": 0 } }` compara PNGs del `--out=`.

`assert` / `wait_until` keys: `disabled`, `visible`, `visible_in_tree`, `text_contains`, `text_equals`, `texture_path_contains`, y `prop` con `equals`, `gte`, `lte` o `contains` (`{ "node": "%Board", "prop": "turn", "equals": 2 }`; `prop` admite puntos). `visible_in_tree: false` también pasa si el nodo ya no está (por ejemplo `queue_free`). `wait_until` también acepta `contains` como alias de `text_contains`, o `{ "node": "%PlaySolo", "signal": "pressed", "timeout": 5 }`.

Cada step imprime `AGENT_STEP n kind`. Errores del engine: `AGENT_STEP_ERROR` y al final `AGENT_ERRORS […]`. `--fail-on-error` tumba el flow si hubo ERROR / SCRIPT ERROR.

`print.prop` admite puntos: `texture.resource_path`.

El autoload **sobrevive** `change_scene`. Un script `-s` no.

Editor visual experimental: `experimental/agent-flow-editor/` (cables → este JSON). Bind al proyecto Godot, pegá `%` / acciones, **Run flow** ejecuta AgentKit con `--fail-on-error`.
