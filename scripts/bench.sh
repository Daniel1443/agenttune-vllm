#!/usr/bin/env bash
# Run one GuideLLM benchmark against an already-running vLLM server.
#   scripts/bench.sh                          # defaults below
#   RATE=4 PROMPT_TOKENS=1024 OUTPUT_TOKENS=256 DURATION=60 scripts/bench.sh
# Writes results/<NAME>.json
# Exit on error, on unset variables, and on failures inside pipes.
set -euo pipefail
# Load shared settings (MODEL, TARGET, RESULTS_DIR, ...) from common.sh.
. "$(dirname "$0")/common.sh"

# Workload knobs: constant arrival rate (req/s), prompt/output length (tokens), run time (s).
RATE="${RATE:-2}"
PROMPT_TOKENS="${PROMPT_TOKENS:-256}"
OUTPUT_TOKENS="${OUTPUT_TOKENS:-128}"
DURATION="${DURATION:-30}"
NAME="${NAME:-bench_$(date +%Y%m%d_%H%M%S)}"

# GuideLLM 0.8 options use the `kind=...,key=value` syntax.
"$GUIDELLM_BIN" run \
  --backend "kind=openai_http,target=${TARGET},model=${MODEL}" \
  --profile "kind=constant,rate=${RATE}" \
  --data "kind=synthetic_text,prompt_tokens=${PROMPT_TOKENS},output_tokens=${OUTPUT_TOKENS}" \
  --constraint "kind=max_duration,seconds=${DURATION}" \
  --output "kind=json,path=${RESULTS_DIR}/${NAME}.json"
