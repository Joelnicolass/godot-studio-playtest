# RULES — AgentKit Example (slice Star Fox)

- **Estilo:** estándar Godot (escena + script juntos). No `src/domain/`.
- **Red:** sin multiplayer. Cero `mp_kit`, cero RPC.
- **3D:** placeholders (`BoxMesh` / `BoxShape3D`). No Blender.
- Composición: contenedor flaco, packed scenes, `@export` / `%UniqueName`, tipos en `Resource` `.tres`.
- Copy de UI en español. IDs de código en inglés.
- Layers 3D: `ship` (1), `obstacle` (2). No duplicar layers en código si ya están en el proyecto.
- Playtest: JSON/harness solo en `res://agent/`. Nunca helpers de flow en `scenes/`.
