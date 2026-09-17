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

Do not use `godot -s /tmp/*.gd`. Use:

```bash
addons/agent_kit/cli.sh /ABS/GODOT_ROOT capture --out=res://agent/out/a.png --wait=1.1 --fail-on-error
addons/agent_kit/cli.sh /ABS/GODOT_ROOT flow --flow=boot_smoke.json --fail-on-error
```

Set `GODOT=` if the binary is not found. Capture/flow **without** `--headless`. JSON and harnesses in `res://agent/` of the game. Report `AGENT_OK` / `AGENT_FAIL` and PNG paths. Turn-based UI: `try_click` + `repeat`.

Optional cable editor: `experimental/agent-flow-editor/` (`pnpm install` && `pnpm dev`). Same JSON as `--agent=flow`.

A playtest still needs user OK (`godot-playtest`). This is not an MCP.
