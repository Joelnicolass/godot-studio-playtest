---
name: godot-playtest
description: >-
  Launches the Godot 4 binary and exercises acceptance criteria like a
  player (run scene, click, screenshot, AgentKit flow). Use when a slice
  needs a playtest or studio-playtester is invoked. Does not wait for
  permission. Returns NEED_SETUP to the caller when the starting context
  is missing. Never creates playtest files outside res://agent/. Never
  edits business rules.
---

# Playtest

Run the **game** and check this slice as a player would. Not unit tests.

Do not wait for permission to playtest. Validate limits yourself ([evaluate.md](evaluate.md)).

If the slice needs a starting context you cannot see in the product scene and the caller did not send `PLAYTEST_SETUP`, return only `NEED_SETUP` to whoever invoked you (agent or human) and stop. Template: [plan.md](plan.md). When they relaunch with `PLAYTEST_SETUP`, build the fixture from those initial conditions and continue.

## 0. Self-check

You may create flows, fixtures and harness files under `res://agent/` only. Do not edit business rules (`scenes/`, `src/`, resources, `project.godot`, InputMap). Put the tree in the report; do not stop for `PLAN_OK`. Template: [plan.md](plan.md).

Player actions are InputMap `press` or a real UI control (`click` / `type`). A missing action is a product bug — do not send keycodes and do not add the mapping. The harness does not move or force state.

## 1. What to exercise

**All** acceptance criteria of **this** slice (the user request; FEATURES/RFC only if the game already has them). Not a sample of 3–7. If it does not fit in ~15 steps, the slice was too big: cover it and list what was left out. Each step must **fail in view** if the bug remains.

If `addons/agent_kit/` exists: `inspect --unique` and `info` (InputMap) first. Use the product scene when the criterion already starts there. Otherwise `"scene"` is `res://agent/fixtures/…` built from `PLAYTEST_SETUP` (product packed scenes, initial state only). Drive the action with an InputMap `press` that already exists, or `click` / `type` on the control the player would use. Do not `call` a method to skip that. Do not teleport or set `velocity`. If `press` returns `unmapped input`, report a product bug and stop. Nothing you create leaves `res://agent/`.

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

- Command, scene, JSON if you ran a flow. Name the fixture vs main, InputMap actions, and whether hooks were reused.
- Each criterion / step: PASS / FAIL + evidence (PNG, `AGENT_PRINT`, console).
- Console: `AGENT_ERRORS` and `ERROR:` / `SCRIPT ERROR:` / `WARNING:`. A script error is FAIL.
- What you could not exercise (no display, missing save, …).
- Process FAIL if any new/edited path is outside `agent/`. Paste `git diff --name-only`.
- Do not rewrite systems. Do not judge look.
