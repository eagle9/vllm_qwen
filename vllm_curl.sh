#!/usr/bin/env bash
# Usage: ./vllm_curl.sh ["your prompt"]
# VLLM_HOST defaults to localhost. From the Mac on home Wi-Fi use VLLM_HOST=192.168.0.140.
# The prompt must not contain double quotes.
HOST="${VLLM_HOST:-localhost}"
PROMPT="${1:-Explain Calculus simply.}"

curl -sS "http://$HOST:8000/v1/chat/completions" \
-H "Content-Type: application/json" \
-d '{
  "model":"Qwen/Qwen3-8B",
  "messages":[{"role":"user","content":"'"$PROMPT"' /no_think"}],
  "temperature":0,
  "max_tokens":300
}'
echo
