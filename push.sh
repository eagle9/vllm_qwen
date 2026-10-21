#!/usr/bin/env bash
# Run on the Mac. Copies this folder's scripts and docs to ~/projects/vllm_qwen on the DGX.
set -euo pipefail
DGX_HOST="${DGX_HOST:-192.168.0.140}"
cd "$(dirname "$0")"

ssh "shaun@$DGX_HOST" 'mkdir -p ~/projects/vllm_qwen'
scp serve_qwen8.sh vllm_curl.sh check.sh *.md "shaun@$DGX_HOST:~/projects/vllm_qwen/"
echo "Copied to shaun@$DGX_HOST:~/projects/vllm_qwen"
