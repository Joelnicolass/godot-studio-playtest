---
name: godot-playtest
description: >-
  Launches the Godot 4 binary and exercises acceptance criteria like a
  player (run scene, click, screenshot, AgentKit flow). Use when the user
  agreed to a playtest, studio-playtester is invoked, or when writing
  AgentKit flows or harnesses. Never create playtest files outside res://agent/.
---

# Playtest

Run the **game** and check this slice as a player would. Not unit tests.

Only after the user **agreed** to this playtest. Do not assume yes.

## 0. Plan before files

If you will **create or edit** flows, harnesses or fixtures: stop and publish `PLAYTEST_PLAN` to the user or the parent agent — objective, each file and why, architecture tree under `res://agent/` only. Wait for `PLAN_OK` / `PLAYTEST_PLAN_OK`. Template: [plan.md](plan.md). Then write **only** those paths.

Do not invent `scenes/test_*.tscn` or helpers beside product actors. Isolation: [harness.md](../godot-agent-kit/harness.md).

## 1. What to exercise

**All** acceptance criteria of **this** slice (the user request; FEATURES/RFC only if the game already has them). Not a sample of 3–7. If it does not fit in ~15 steps, the slice was too big: cover it and list what was left out. Each step must **fail in view** if the bug remains.

If `addons/agent_kit/` exists: `inspect --unique`, write the flow in `res://agent/flows/`. Helpers only in `res://agent/harness/`. Fixture `.tscn` only in `res://agent/fixtures/`. The harness **may** `call()` methods the product already has, including `_prefixed` ones. Nothing AgentKit-related leaves `res://agent/`.

## 2. Launch

1. Binary: `cli.sh` finds Godot, or set `GODOT=`.
2. `--path` = folder with `project.godot`.
3. Prefer a **window** (`--resolution` from `project.godot`) for input and pixels. Headless only for parse/load.
4. Use `--fail-on-error` on capture/flow.

## 3. Capture

Prefer AgentKit:

```bash
addons/agent_kit/cli.sh /ABS/GODOT_ROOT inspect --unique
addons/agent_kit/cli.sh /ABS/GODOT_ROOT capture --out=res://agent/out/playtest.png --wait=1.1 --fail-on-error
addons/agent_kit/cli.sh /ABS/GODOT_ROOT flow --flow=boot_smoke.json --out=res://agent/out --fail-on-error
```

Grep `AGENT_OK`, `AGENT_FAIL`, `AGENT_STEP`, `AGENT_STEP_ERROR`, `AGENT_ERRORS`, `ERROR:`, `SCRIPT ERROR:`, `WARNING:`. Turn-based UI: `try_click` + `repeat`. **Do not** `godot -s /tmp/capture.gd`.

`--fail-on-error` fails the run if the engine logged ERROR / SCRIPT ERROR even when clicks “worked”. Include that log in the report.

If the addon is missing, temporary fallback: [capture.md](capture.md). Headless does not give pixels.

## 4. Report

- Command, scene, JSON if you ran a flow.
- Each criterion / step: PASS / FAIL + evidence (PNG, `AGENT_PRINT`, console).
- Console: `AGENT_ERRORS` and `ERROR:` / `SCRIPT ERROR:` / `WARNING:`. A script error is FAIL.
- What you could not exercise (no display, missing save, …).
- Process FAIL if any new/edited path is outside `agent/`. Paste `git diff --name-only`.
- Do not rewrite systems. Do not judge look.
