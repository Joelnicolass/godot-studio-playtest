#!/usr/bin/env bash
# Suite de flows AgentKit del example (casos principales F1).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CLI="$ROOT/addons/agent_kit/cli.sh"

FLOWS=(
	boot_ready.json
	enter_run.json
	crash_center.json
	dodge_left.json
	fly_over.json
	crash_side.json
)

failed=0
for flow in "${FLOWS[@]}"; do
	echo "===== $flow ====="
	if ! "$CLI" "$ROOT" flow --flow="$flow" --out=res://agent/out --fail-on-error; then
		echo "SUITE_FAIL $flow"
		failed=1
		break
	fi
done

if [[ "$failed" -eq 0 ]]; then
	echo "SUITE_OK ${#FLOWS[@]} flows"
fi
exit "$failed"
