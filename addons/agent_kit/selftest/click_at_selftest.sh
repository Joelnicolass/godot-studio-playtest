#!/usr/bin/env bash
# Self-test of the click_at flow step: headless, no window, no game content (~5 s).
#   bash addons/agent_kit/selftest/click_at_selftest.sh [GODOT_PROJECT]
# GODOT_PROJECT: a Godot project that has this addon (default: the project that holds addons/agent_kit).
# Godot goes through the machine queue (determinism/harness/godot_run.sh, headless slot).
# Runs selftest/click_at.json in three window setups and the error cases (click_at_selftest.gd).
# Prints CLICK_AT_SELFTEST PASS or CLICK_AT_SELFTEST FAIL; exit 0 or 1.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
PROJECT="${1:-$(cd "$HERE/../../.." && pwd)}"
if [ ! -f "$PROJECT/project.godot" ]; then
  echo "No project.godot in $PROJECT: pass a Godot project that has addons/agent_kit" >&2
  echo "CLICK_AT_SELFTEST FAIL"
  exit 2
fi
if [ -z "${GODOT_BIN:-}" ]; then
  GODOT_BIN="${GODOT:-}"
fi
if [ -z "$GODOT_BIN" ]; then
  GODOT_BIN="$(command -v godot godot4 Godot 2>/dev/null | head -n1)"
  [ -z "$GODOT_BIN" ] && [ -x /Applications/Godot.app/Contents/MacOS/Godot ] && GODOT_BIN=/Applications/Godot.app/Contents/MacOS/Godot
fi
if [ -z "$GODOT_BIN" ]; then
  echo "Godot 4 binary not found: set GODOT_BIN=/path/to/Godot" >&2
  echo "CLICK_AT_SELFTEST FAIL"
  exit 2
fi
export GODOT_BIN
log="$(mktemp)"
trap 'rm -f "$log"' EXIT
perl -e 'alarm 120; exec @ARGV' bash "$HERE/../determinism/harness/godot_run.sh" \
  "$GODOT_BIN" --headless --path "$PROJECT" res://addons/agent_kit/selftest/click_at_selftest.tscn > "$log" 2>&1
code=$?
grep -E "^(CLICK_AT_SELFTEST|AGENT_CLICK|AGENT_FAIL)|ERROR|Error" "$log"
if [ "$code" = 0 ] && grep -q "^CLICK_AT_SELFTEST PASS" "$log" && ! grep -qE "SCRIPT ERROR|^ERROR" "$log"; then
  exit 0
fi
[ "$code" != 0 ] && echo "godot exit code $code"
grep -q "^CLICK_AT_SELFTEST FAIL$" "$log" || echo "CLICK_AT_SELFTEST FAIL"
exit 1
