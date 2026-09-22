# Plan de playtest

No esperes OK para jugar. Validá los límites de [evaluate.md](evaluate.md).

Si falta el contexto para armar el escenario, devolvé **solo** esto a quien te invocó y no escribas archivos. Cuando te relance con `PLAYTEST_SETUP`, usá esas condiciones y seguí.

```
NEED_SETUP
criterio: matar al boss
falta: no hay res://debug/ nombrada en el F<n> o el RFC
no voy a: crear el .tscn ni usar call() para spawnear al boss
```

Quien llama (otro agente o un humano) responde así:

```
PLAYTEST_SETUP
escena: res://debug/boss_dying.tscn
accion: fire
observable: %Boss sale del árbol y %HitLabel muestra Impacto
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
