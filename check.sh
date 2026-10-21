#!/usr/bin/env bash
# Usage: ./check.sh   (VLLM_HOST defaults to localhost)
HOST="${VLLM_HOST:-localhost}"

code=$(curl -s -m 5 -o /dev/null -w "%{http_code}" "http://$HOST:8000/health")
if [ "$code" != "200" ]; then
  echo "Server not ready at $HOST:8000 (health: ${code:-no response})"
  exit 1
fi

echo "Server ready at $HOST:8000"
curl -s -m 5 "http://$HOST:8000/v1/models"
echo
