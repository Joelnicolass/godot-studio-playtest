---
name: godot-agent-kit
description: >-
  Drives a Godot 4 project with the AgentKit CLI: viewport capture,
  click/type/press flows, node inspect, HTTP fetch, PNG diff. Use when
  capturing the game, writing res://agent/ flows or harnesses, or when
  tempted to add playtest helpers to src/. Not an MCP.
---

# AgentKit

Addon `addons/agent_kit/` in the Godot project. Zero gameplay. The agent talks to Godot via CLI; `AGENT_OK` / `AGENT_FAIL` are the contract. JSON, harnesses and dumps live in **`res://agent/`** — not in the addon, not in `src/`.

## When to use

- Capture or run a UI flow (not a made-up PNG).
- Before/after a shader or layout: `capture` + `diff`.
- Download a file into `res://`: `fetch`.
- Understand a scene: `inspect --unique`.
- About to write `godot -s /tmp/*.gd` → stop, use AgentKit.

A human-style playtest still needs user OK (`godot-playtest`).

## Install

```bash
./install.sh --addon /path/to/godot-project
```

Enable plugin **AgentKit**. Without `--agent=`, F5 is unchanged.

## Do not

```bash
godot --path game -s /tmp/capture.gd
```

Game `class_name` scripts compile **before** autoloads. Capture from the AgentKit autoload so it survives `change_scene`.

## Run

```bash
addons/agent_kit/cli.sh /ABS/PROJECT VERB [--flag=value ...]
# GODOT=/path/to/Godot if the binary is not on PATH
```

`cli.sh` adds `--headless` for `info` / `fetch` / `inspect` / `diff`. **Not** for `capture` / `flow` (pixels need a window).

| Verb | Use |
|------|-----|
| `flow` | `--flow=boot_smoke.json` `--out=res://agent/out` `--fail-on-error` |
| `capture` | `--out=res://agent/out/a.png` `--scene=res://...` `--wait=1.1` `--fail-on-error` |
| `diff` | `--a=` `--b=` `--out=` `--threshold=0.02` |
| `inspect` | `--unique` `--node=%CardView` `--scene=` |
| `fetch` | `--url=` `--out=` `--ua=` |
| `info` | viewport, main scene, version, InputMap |

Grep: `AGENT_OK`, `AGENT_FAIL`, `AGENT_SHOT=`, `AGENT_PRINT`, `AGENT_CLICK`, `AGENT_PRESS`, `AGENT_CALL`, `AGENT_STEP`, `AGENT_STEP_ERROR`, `AGENT_ERRORS`, `AGENT_SKIP`, `AGENT_REPEAT`, `AGENT_DIFF`, `AGENT_JSON`.

## Rules

1. Flows in `res://agent/flows/*.json`. Steps: [flows.md](flows.md).
2. Helpers only in `res://agent/harness/*.gd`. Read [harness.md](harness.md) **before** editing a product `.gd`.
3. Do not add spawn / force-state / count / pause helpers to `src/` (`agent_*` or the same role under another name).
4. The harness **may** `call()` methods the product already has, including `_prefixed` ones. GDScript `_` is not runtime-private.
5. Long / turn-based UI: `try_click` + `repeat`, not a hard `click` on a disabled button.

Optional visual editor (not in `./install.sh`): `experimental/agent-flow-editor/` (`pnpm install` && `pnpm dev`).
