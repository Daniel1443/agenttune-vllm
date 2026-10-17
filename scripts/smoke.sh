#!/usr/bin/env bash
# One-command end-to-end check: start vLLM, wait until healthy, run a short
# benchmark, then stop the server. Extra args go to `vllm serve`.
# Exit on error, on unset variables, and on failures inside pipes.
set -euo pipefail
# Load shared settings and wait_for_server() from common.sh.
. "$(dirname "$0")/common.sh"

LOG="$RESULTS_DIR/smoke_vllm.log"
# Trailing `&` runs the server in the background; its output goes to $LOG.
"$VLLM_BIN" serve "$MODEL" --host "$HOST" --port "$PORT" "$@" >"$LOG" 2>&1 &
SERVER_PID=$!
# Always stop the server on exit, even if the benchmark fails.
trap 'kill "$SERVER_PID" 2>/dev/null || true; wait "$SERVER_PID" 2>/dev/null || true' EXIT

echo "Waiting for vLLM (log: $LOG)..."
wait_for_server "${STARTUP_TIMEOUT:-300}" || { tail -n 30 "$LOG" >&2; exit 1; }

DURATION="${DURATION:-15}" NAME="${NAME:-smoke}" "$(dirname "$0")/bench.sh"
echo "OK: results in $RESULTS_DIR/${NAME:-smoke}.json"
