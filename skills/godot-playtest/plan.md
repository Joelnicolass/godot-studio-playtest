# Plan de playtest

No esperes OK para jugar. Validá los límites de [evaluate.md](evaluate.md).

Si falta el contexto para armar el escenario, devolvé **solo** esto a quien te invocó y no escribas archivos. Cuando te relance con `PLAYTEST_SETUP`, usá esas condiciones y seguí.

```
NEED_SETUP
criterio: esquivar el cubo del centro
falta:
- packed scenes: …
- estado inicial: posición, .tres que ya existe, qué nodos están
- acción o control: …
- observable al final: …
```

Quien llama (otro agente o un humano) responde así:

```
PLAYTEST_SETUP
escenas: res://scenes/actors/ship.tscn, res://scenes/actors/obstacle.tscn
estado: nave en el origen, cubo en (0, 0, -28), match_rules.tres del producto
accion: move_left
observable: %HpLabel sigue en HP 1 y %CrashBanner oculto
```

El árbol va en el informe, después de poder jugar. No frena el trabajo si las condiciones ya están.

```
PLAYTEST_PLAN
objetivo: …
escena: agent/fixtures/rail_dodge.tscn (no main: el criterio es esquivar)
input: press move_left (ya está en el InputMap; si no, BUG)
hooks: ninguno — el JSON alcanza
límites: solo agent/; cero reglas de negocio

agent/
├── flows/dodge_left.json
├── fixtures/rail_dodge.tscn
└── out/
```

Si una acción no está mapeada en el editor, no armes el flow con un keycode: reportá el bug y parate.

Si reimportar no registra el `class_name`, devolvé solo esto y no sigas el slice:

```
CACHE_STALE
tipo: ShipGun
script: res://scenes/components/ship_gun.gd
error: Could not find type "ShipGun"
importe: una vez, el error volvió
```

Quien llama corre el import o corrige el proyecto, y relanza el playtest.
