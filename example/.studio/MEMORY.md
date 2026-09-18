# Memoria del ejemplo (Star Fox slice)

## 2026-09-17

**What**: F1 choque contra cubos placeholder en rail 3D
**Why**: pedido de feature tipo Star Fox + playtest AgentKit
**Where**: `example/scenes/world/run.tscn`, `actors/obstacle.tscn`, `actors/ship.tscn`, `resources/obstacles/`
**Learned**: `class_name` en CLI exige `.godot/global_script_class_cache.cfg` (git). El rail no andaba hasta un `_ready` que resuelve `actor` al parent. Hurtbox vs StaticBody3D no disparó; obstáculos como `Area3D` monitorable + `area_entered` sí.

### architecture/standard-no-mp

Estándar Godot, sin MP, cubos placeholder (no Blender).
