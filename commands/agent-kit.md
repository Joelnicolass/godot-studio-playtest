---
name: agent-kit
description: >-
  Capture, run a UI flow, inspect nodes, HTTP-fetch, or PNG-diff a Godot 4
  project with AgentKit. Use when the user wants screenshots or clicks instead
  of godot -s /tmp.
---

Load skill `godot-agent-kit`. If `addons/agent_kit/` is missing next to `project.godot`, install it from this repo and ask to enable plugin **AgentKit**:

```bash
./install.sh --addon /ABS/GODOT_ROOT
```

**Isolation:** anything you create stays in `res://agent/` (flows, harness, fixtures, out). Do not edit business rules or InputMap. Do not wait for user OK — check those limits yourself (`evaluate.md`).

**Play:** use the product scene when the slice already starts there. If the context is missing, return only `NEED_SETUP` to whoever called you (agent or human) and wait for `PLAYTEST_SETUP` — initial conditions, not permission. Then build `agent/fixtures/` from that. Actions are InputMap `press` that already exist, or `click` / `type` on the player’s control. Missing action = product bug (`unmapped input`). No keycodes. No harness func that moves or forces state. Skill `godot-playtest` → `plan.md`.

Do not use `godot -s /tmp/*.gd`. Use:

```bash
addons/agent_kit/cli.sh /ABS/GODOT_ROOT capture --out=res://agent/out/a.png --wait=1.1 --fail-on-error
addons/agent_kit/cli.sh /ABS/GODOT_ROOT flow --flow=boot_smoke.json --fail-on-error
```

Set `GODOT=` if the binary is not found. Capture/flow **without** `--headless`. JSON, harnesses, fixture scenes and PNG dumps in `res://agent/` of the game — nowhere else. Report `AGENT_OK` / `AGENT_FAIL` and PNG paths. Turn-based UI: `try_click` + `repeat`. `git diff --name-only` must stay under `agent/`.

Optional cable editor: `experimental/agent-flow-editor/` (`pnpm install` && `pnpm dev`). Same JSON as `--agent=flow`.

A playtest does not wait for user OK. The agent only writes under `res://agent/` and does not change business rules. This is not an MCP.
