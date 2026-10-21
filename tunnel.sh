#!/usr/bin/env bash
# Run on the Mac. Forwards the DGX vLLM API to http://localhost:8000.
# Away from home, set DGX_HOST to the Tailscale name: DGX_HOST=edgexpert-78e7 ./tunnel.sh
DGX_HOST="${DGX_HOST:-192.168.0.140}"

ssh -N -L 8000:localhost:8000 "shaun@$DGX_HOST"
