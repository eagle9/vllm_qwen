#!/usr/bin/env bash
# Run on the DGX box.
set -euo pipefail

SNAPSHOT="$HOME/.cache/huggingface/hub/models--Qwen--Qwen3-8B/snapshots/b968826d9c46dd6066d109eabc6255188de91218"

if [ ! -f "$SNAPSHOT/config.json" ]; then
  echo "Model not found at $SNAPSHOT" >&2
  echo "See download-model.md" >&2
  exit 1
fi

source "$HOME/vllm-env/bin/activate"

# The saved Hugging Face token is expired; offline mode keeps vLLM from sending it.
export HF_HUB_OFFLINE=1

exec vllm serve "$SNAPSHOT" \
  --served-model-name Qwen/Qwen3-8B \
  --host 0.0.0.0 \
  --port 8000 \
  --dtype bfloat16 \
  --max-model-len 4096 \
  --gpu-memory-utilization 0.75 \
  --enforce-eager
