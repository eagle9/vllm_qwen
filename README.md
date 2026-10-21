# Serve Qwen3-8B with vLLM on the DGX

This folder runs the Qwen3-8B language model on the DGX Spark box at home and lets you ask it questions over HTTP.

- **DGX box:** `shaun@192.168.0.140`, host `edgexpert-78e7`, NVIDIA GB10 GPU
- **Server:** vLLM 0.23.0 in `~/vllm-env`, PyTorch 2.11.0+cu130
- **API:** OpenAI-compatible, on port 8000, model name `Qwen/Qwen3-8B`

Everything is already installed and the model is already downloaded. If you are coming back after a while, start at Quick start.

## Files

| File | Runs on | What it does |
| --- | --- | --- |
| `enter.sh` | Mac | SSH into the DGX |
| `push.sh` | Mac | Copy these scripts and docs to `~/projects/vllm_qwen` on the DGX |
| `serve_qwen8.sh` | DGX | Start the vLLM server from the local model files |
| `check.sh` | Either | Check the server is up and list the model |
| `vllm_curl.sh` | Either | Send one question to the model |
| `tunnel.sh` | Mac | Forward the DGX API to `localhost:8000` on the Mac |
| `setup-pytorch-vllm.md` | - | One-time install of PyTorch and vLLM |
| `download-model.md` | - | Download the model again if it is missing |

## Quick start

**1. Copy the scripts to the DGX** (only needed after editing them here):

```bash
./push.sh
```

**2. Log in and start the server inside tmux**, so it keeps running after you close the laptop:

```bash
./enter.sh
tmux new -s vllm
~/projects/vllm_qwen/serve_qwen8.sh
```

Wait for `Application startup complete`. Loading takes about a minute. Then detach with `Ctrl-b` followed by `d`. The server keeps running. You can now exit SSH.

**3. Check it**, from the Mac:

```bash
VLLM_HOST=192.168.0.140 ./check.sh
```

**4. Ask a question:**

```bash
VLLM_HOST=192.168.0.140 ./vllm_curl.sh "What is a derivative?"
```

On the DGX itself, leave out `VLLM_HOST` (it defaults to `localhost`).

## Reading the answer

The reply is JSON. The answer is in `choices[0].message.content`. Qwen3 normally "thinks" before it answers, and `vllm_curl.sh` adds `/no_think` to skip that, so the answer starts with an empty `<think></think>` block. `finish_reason` `stop` means the model finished on its own. `length` means it hit the 300-token limit `max_tokens`.

## Stop the server

```bash
./enter.sh
tmux attach -t vllm
```

Press `Ctrl-c`, then type `exit` to close the tmux session. Check the GPU is free with `nvidia-smi`.

## Away from home

`192.168.0.140` only works on home Wi-Fi. Both the DGX and the Mac are on Tailscale, account `eagle9`. Turn Tailscale on in the Mac menu bar, then use the DGX's Tailscale name:

```bash
ssh shaun@edgexpert-78e7
DGX_HOST=edgexpert-78e7 ./tunnel.sh
```

While `tunnel.sh` is running, `./check.sh` and `./vllm_curl.sh` on the Mac reach the server through `localhost:8000`. The DGX must be left powered on.

## Troubleshooting

**`401 Client Error` or `Repository Not Found` on start.** You ran `vllm serve Qwen/Qwen3-8B` by name. The saved Hugging Face token expired on 2026-07-17. Use `serve_qwen8.sh`, which loads the local files offline. Details are in `download-model.md`.

**`Model not found` from `serve_qwen8.sh`.** The model cache was deleted. Follow `download-model.md`.

**`Address already in use` on port 8000.** A server is already running. Run `./check.sh`, or `tmux ls` on the DGX to find it.

**`check.sh` says not ready right after start.** The model is still loading. Wait a minute and retry.

**`CUDA out of memory`.** Something else holds the GPU. Check with `nvidia-smi` and stop it. `--gpu-memory-utilization 0.75` in `serve_qwen8.sh` reserves 75% of GPU memory for vLLM.

**`vllm: command not found`.** The venv is not active. `serve_qwen8.sh` activates it. For manual commands run `source ~/vllm-env/bin/activate`.

## Old files

`~/projects/jalgo` on the DGX holds the earlier experiments. `~/projects/jalgo/vllm_serve_qwen8.sh` uses the model name and now fails with the 401 above.
