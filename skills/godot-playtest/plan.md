# Plan de playtest (antes de archivos)

Antes de **crear o editar** JSON, harness, fixtures o cualquier archivo de AgentKit, publicá el plan al usuario o al agente que te invocó. No escribas el disco hasta que haya `PLAN_OK` (humano: un OK corto; subagente: el prompt padre incluye `PLAYTEST_PLAN_OK`).

Correr un flow **ya existente** o `inspect` sin archivos nuevos no exige este gate. Capturas van a `res://agent/out/` (gitignored).

## Qué publicar

1. **Objetivo** — qué criterios del slice se van a ejercer.
2. **Corte** — fixture aislada vs main; hooks que se **reusan**; acciones de InputMap del jugador (no warp).
3. **Archivos** — path + por qué existe cada uno (un renglón).
4. **Árbol** — solo `res://agent/`. Nada fuera.

Plantilla:

```
PLAYTEST_PLAN
objetivo: …
escena: agent/fixtures/rail_dodge.tscn (no main: el criterio es esquivar, no el boot)
input: press move_left / move_up (InputMap del jugador)
hooks: reuso play_via_private — sin func nueva
por qué no alcanza con clicks solos: … (o: alcanza)

archivos:
- agent/fixtures/rail_dodge.tscn — ship + un cubo; packed scenes del producto
- agent/flows/dodge_left.json — press move_left, assert HP
- agent/harness/hooks.gd — sin cambios (reuso)

árbol:
agent/
├── flows/
│   └── dodge_left.json
├── harness/
│   └── hooks.gd
├── fixtures/
│   └── rail_dodge.tscn
└── out/
```

Si el padre relanza con `PLAYTEST_PLAN_OK`, implementá **ese** árbol. No agregues escenas de test en `scenes/` “porque era más fácil”. Criterio de corte: [evaluate.md](evaluate.md).
