#!/usr/bin/env bash
# Shared settings for all scripts. Source this file; do not run it.
# Override any value via environment variables or a local .env file (gitignored).

# Repo root = parent of scripts/, so scripts work from any working directory.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# `set -a` exports every variable defined in .env.
if [ -f "$REPO_ROOT/.env" ]; then
  set -a; . "$REPO_ROOT/.env"; set +a
fi

# `${VAR:-default}` keeps $VAR if already set, otherwise uses the default.
VLLM_BIN="${VLLM_BIN:-vllm}"
GUIDELLM_BIN="${GUIDELLM_BIN:-guidellm}"
MODEL="${MODEL:-Qwen/Qwen2.5-1.5B-Instruct}"
HOST="${HOST:-127.0.0.1}"
PORT="${PORT:-8000}"
TARGET="http://${HOST}:${PORT}"
RESULTS_DIR="${RESULTS_DIR:-$REPO_ROOT/results}"
mkdir -p "$RESULTS_DIR"

# Block until the vLLM server answers /health, or fail after $1 seconds.
wait_for_server() {
  local timeout="${1:-180}" i=0
  until curl -sf "$TARGET/health" >/dev/null 2>&1; do
    i=$((i + 1))
    if [ "$i" -ge "$timeout" ]; then
      echo "vLLM server did not become healthy within ${timeout}s" >&2
      return 1
    fi
    sleep 1
  done
}
