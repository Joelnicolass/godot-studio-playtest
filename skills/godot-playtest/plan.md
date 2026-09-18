# Plan de playtest (antes de archivos)

Antes de **crear o editar** JSON, harness, fixtures o cualquier archivo de AgentKit, publicá el plan al usuario o al agente que te invocó. No escribas el disco hasta que haya `PLAN_OK` (humano: un OK corto; subagente: el prompt padre incluye `PLAYTEST_PLAN_OK`).

Correr un flow **ya existente** o `inspect` sin archivos nuevos no exige este gate. Capturas van a `res://agent/out/` (gitignored).

## Qué publicar

1. **Objetivo** — qué criterios del slice se van a ejercer.
2. **Archivos** — path + por qué existe cada uno (un renglón).
3. **Árbol** — solo `res://agent/`. Nada fuera.

Plantilla:

```
PLAYTEST_PLAN
objetivo: …
por qué no alcanza con clicks solos: … (o: alcanza)

archivos:
- agent/flows/crash_center.json — choque en el rail, sin input
- agent/harness/hooks.gd — call("_on_play") que el boot ya tiene

árbol:
agent/
├── flows/
│   └── crash_center.json
├── harness/
│   └── hooks.gd
├── fixtures/          # solo si el flow necesita un .tscn/.tres de run
└── out/               # PNG del CLI; no es producto
```

Si el padre relanza con `PLAYTEST_PLAN_OK`, implementá **ese** árbol. No agregues escenas de test en `scenes/` “porque era más fácil”.
