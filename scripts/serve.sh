#!/usr/bin/env bash
# Start a vLLM server in the foreground. Extra args are passed to `vllm serve`.
#   scripts/serve.sh
#   MODEL=Qwen/Qwen2.5-0.5B-Instruct scripts/serve.sh --max-num-seqs 16
# Exit on error, on unset variables, and on failures inside pipes.
set -euo pipefail
# Load shared settings (MODEL, HOST, PORT, ...) from common.sh next to this file.
. "$(dirname "$0")/common.sh"

# `exec` replaces this shell with vLLM; "$@" forwards any extra CLI args.
exec "$VLLM_BIN" serve "$MODEL" --host "$HOST" --port "$PORT" "$@"
