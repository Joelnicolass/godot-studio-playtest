# Features

## F1 — Chocar contra obstáculos (cubos)

Rail shooter 3D mínimo (estilo Star Fox). Placeholders: cubos. Sin disparo, enemigos, anillos ni modelos.

### El jugador

Entra desde **Jugar**. La nave avanza sola por el corredor. Puede desviarse. Si pega un cubo, pierde HP; a 0 HP choca y se ve el aviso.

### Criterios

1. **Jugar** carga `res://scenes/world/run.tscn` (carrera 3D, no el label del boot).
2. En el corredor hay **cubos** (`obstacle.tscn` + `ObstacleData`). Tamaño/daño en `.tres`; color u offset de instancia en `@export` / escena.
3. La nave avanza **sola** (rail). InputMap `move_left` / `move_right` / `move_up` / `move_down` desvía en el plano local.
4. Contacto nave–cubo aplica daño de `ObstacleData` a `Health`. HP inicial en `MatchRules`. A 0 HP: señal `crashed` y HUD `%CrashBanner` visible.
5. Un cubo (`%ObstacleOnRail`) está **en el centro del rail**: sin input, el choque ocurre solo.
6. `obstacle.tscn` y `ship.tscn` se pueden F6. Knobs en el inspector; no pisar `@export` en `_ready`.
7. Nada de spawn/forzar/contar/pausar para el agente en `scenes/`. Copy de UI en español.

### Fuera de alcance

Disparo, enemigos, anillos, bosses, juice, Blender/Aseprite, multiplayer, GUT.
