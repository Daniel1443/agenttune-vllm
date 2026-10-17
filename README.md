# AgentTune: LLM Agents as Autotuners for SLO-Constrained LLM Serving

Course project for CSCI-GA 3033-091 (NYU, Fall 2026) by Sih-Han Chao and Sz-Je Huang.

**Research question.** Can an LLM agent that reads profiling feedback find vLLM
serving configurations that meet a latency SLO with higher goodput, in fewer
trials, than grid search or Bayesian optimization?

> Status: work in progress. Only commands that have been run and verified are
> documented below. Sections marked TODO are not yet verified.

## Prerequisites

- [uv](https://docs.astral.sh/uv/) (tested with 0.9.18)
- A model in the Hugging Face cache (default: `Qwen/Qwen2.5-1.5B-Instruct`)
- One of:
  - macOS 15+ on Apple Silicon with [Homebrew](https://brew.sh) (local development only)
  - Linux with an NVIDIA GPU (for the real experiments)

Design note: the project environment (agent, harness, GuideLLM) and the vLLM
server are installed separately. vLLM is the system under test and is only
accessed through its HTTP API.

## Setup

### 1. Project environment (all platforms)

```bash
uv sync
uv run guidellm --version   # expected: guidellm version: 0.8.1
```

### 2. vLLM server

**macOS (Apple Silicon, Metal backend)**

```bash
brew tap vllm-project/vllm-metal https://github.com/vllm-project/vllm-metal
brew install vllm-project/vllm-metal/vllm-metal
vllm --version              # expected: 0.31.0+cpu (the Metal plugin is installed separately)
```

**Linux (CUDA)**

TODO: not yet verified. Planned: an isolated vLLM install that puts `vllm` on `PATH`.

The scripts only require that the `vllm` command is on `PATH`, so they are the
same on both platforms. Numbers measured on macOS are for debugging only; all
reported results come from the CUDA machine.

## Quick start

Start a vLLM server (keep this terminal open):

```bash
scripts/serve.sh
```

Send one request from another terminal:

```bash
curl -s http://127.0.0.1:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"Qwen/Qwen2.5-1.5B-Instruct","messages":[{"role":"user","content":"Say hi in one sentence."}],"max_tokens":32}'
```

TODO: benchmark with `scripts/bench.sh` and the one-command `scripts/smoke.sh`
(not yet passing).

## Scripts

| Script | Purpose |
|---|---|
| `scripts/common.sh` | Shared settings (model, host, port); sourced by the other scripts |
| `scripts/serve.sh` | Start a vLLM server in the foreground; extra args go to `vllm serve` |
| `scripts/bench.sh` | Run one GuideLLM benchmark against a running server |
| `scripts/smoke.sh` | Start server, run a short benchmark, stop server |

Settings can be overridden with environment variables or a local `.env` file
(see `.env.example`).

## Repository layout

```
scripts/      Shell scripts to run vLLM and benchmarks
pyproject.toml, uv.lock   Project environment (locked versions)
```

Planned: `src/` (agent and harness), `experiments/`, `demo/`, `tests/`, `docs/`, `data/`.
