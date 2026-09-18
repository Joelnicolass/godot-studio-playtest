# Harness AgentKit

Read this **before** writing a playtest helper. Typical failure: the flow cannot set up state with clicks, so the agent drops a test scene or `agent_*` into product folders. Prefix `agent_*` or a gameplay-looking name — same contamination. **Who calls it** matters, not the name. **Where the file lives** matters more.

Before any new playtest file: publish `PLAYTEST_PLAN` ([plan.md](../godot-playtest/plan.md)). Do not write until `PLAN_OK`.

## Isolation — everything stays in `res://agent/`

AgentKit work **never** leaves that directory. New scripts, packed scenes, Resources, JSON, PNG dumps, suite shells — all of it.

| Path | Playtest? |
|------|-----------|
| `res://agent/flows/*.json` | yes |
| `res://agent/harness/*.gd` | yes (`extends Node`, **no** `class_name`) |
| `res://agent/fixtures/` | yes (run-only `.tres` / `.tscn`) |
| `res://agent/out/` | yes (CLI PNG; gitignored) |
| `src/`, `scenes/`, `tests/`, product glue | **no** |

Forbidden even with a “test_” name: `scenes/test_crash.tscn`, `scenes/world/agent_arena.tscn`, `tests/playtest_*.gd`, dummy actors next to the ship. For an isolated feature, **do** make a throwaway world — in `res://agent/fixtures/` — that instances product packed scenes. Do not launch the main scene unless the criterion is boot/hub. How to choose: [evaluate.md](../godot-playtest/evaluate.md).

Stop before editing anything outside `res://agent/`. If the change only serves the flow, it belongs in the harness. Product bugs you found while playing are a **report**, not a playtest patch in `scenes/`.

## Product must not grow playtest APIs

Do not add a product method whose job, for the flow, is to spawn, force a state, count nodes, pause systems, or rebuild the world. `func agent_*` is forbidden; the same role under another name is too.

A public product API is allowed only if the **game** already needs it (load, generator, editor, replay). If the only caller is the flow or `res://agent/`, it is playtest → harness.

## `call()` on `_methods`

GDScript `_` is a [naming convention](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html#functions-and-variables), not runtime privacy. [`Object.call`](https://docs.godotengine.org/en/stable/classes/class_object.html#class-object-method-call) / `callv` / `has_method` run the method if it exists.

Use that **before** asking for a new public API:

```gdscript
# res://agent/harness/hooks.gd
extends Node

func play_via_private() -> String:
	var scene := get_tree().current_scene
	if scene == null:
		return "no_scene"
	if not scene.has_method("_on_play"):
		return "missing__on_play"
	scene.call("_on_play")
	return "ok"
```

```json
{ "call": { "harness": "hooks", "method": "play_via_private" } }
{ "call": { "node": ".", "method": "_on_play" } }
```

AgentKit does not block `_`. It blocks `free` / `queue_free` / `replace_by` / `set_script`.

Calling an **existing** `_method` does **not** justify adding `_setup_for_agent` (or a public twin) on the product.

## Order

1. Isolated fixture in `res://agent/fixtures/` for the feature (not the main scene). JSON `"scene"` points there.
2. Clicks / InputMap `press` / `wait_until` as a player. Do not teleport or assign `velocity` / `global_position` to fake the action.
3. Reuse an existing method on `res://agent/harness/hooks.gd`. Add a **generic** helper only if JSON cannot do it. No one-shot `func` per flow; do not let `hooks.gd` become a kitchen sink.
4. In the harness: current scene, `%UniqueName`, `find_children`, existing packed scenes, public signals, and `call()` / `callv()` on methods the product already has. Count with `find_children`, not a new getter. `call("_on_play")` is for what a button would already do, not physics.

## Stop

These do **not** keep the product clean:

- A test scene anywhere except `res://agent/fixtures/`.
- Launching the whole game when a fixture of packed scenes would isolate the criterion.
- A new harness `func` per JSON, or forcing motion in GDScript instead of InputMap `press`.
- Extending a product class from `agent/`.
- Renaming `agent_*` to a gameplay-looking name.
- Adding a public or new `_private` method only for the flow.
- `set("_ref", …)` to replace internals, or duplicating a product scene under `scenes/` just for the run.

## Done check

```bash
rg -n "func agent_" src scenes
git diff --name-only
```

Zero `func agent_`. Every path in the playtest diff must be under `agent/` (or gitignored `agent/out/`). No product methods unless the **game** already calls that API.
