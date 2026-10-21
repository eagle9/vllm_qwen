# Download Qwen3-8B from Hugging Face

The model is already on the DGX box. It was downloaded on 2026-06-23 (17:40 to 17:56), most likely by the first run of `~/projects/jalgo/qwen.py` through `transformers`. The current server does not download anything: `HF_HUB_OFFLINE=1` makes vLLM read the local snapshot.

Only follow this note if the cache is missing or incomplete.

## Check what is on disk

On the DGX, in `~/vllm-env`:

```bash
ls ~/.cache/huggingface/hub/models--Qwen--Qwen3-8B/snapshots
du -sh ~/.cache/huggingface/hub/models--Qwen--Qwen3-8B
find ~/.cache/huggingface/hub/models--Qwen--Qwen3-8B -name "*.incomplete"
```

A complete copy is about 16G in the blobs directory. The snapshot `b968826d9c46dd6066d109eabc6255188de91218` has five shards, `model-00001-of-00005.safetensors` through `model-00005-of-00005.safetensors`. The last command should print nothing.

## Fix the token first

Qwen3-8B is public, so no Hugging Face account is needed. The problem is the token saved on 2026-07-17: it has expired, and every hub request sends it and gets HTTP 401 ("Repository Not Found").

```bash
source ~/vllm-env/bin/activate
hf auth logout
```

To use an account later (private or gated repos only), create a token at [huggingface.co/settings/tokens](https://huggingface.co/settings/tokens) and run `hf auth login --force`.

## Download

Pin the same revision that is in the cache now, so the snapshot path in `README.md` stays the same:

```bash
source ~/vllm-env/bin/activate
hf download Qwen/Qwen3-8B --revision b968826d9c46dd6066d109eabc6255188de91218
```

Files go to `~/.cache/huggingface/hub/models--Qwen--Qwen3-8B`. Rerunning the command skips files that are already complete and resumes partial ones. Use `--dry-run` to see what it would fetch.

Dropping `--revision` downloads the latest `main`. That can create a different snapshot hash, so update the path in the serve command to match:

```bash
ls ~/.cache/huggingface/hub/models--Qwen--Qwen3-8B/snapshots
```

## Let vLLM download it instead

With the expired token removed, vLLM downloads into the same cache on first start:

```bash
source ~/vllm-env/bin/activate
vllm serve Qwen/Qwen3-8B \
  --dtype bfloat16 \
  --max-model-len 4096 \
  --gpu-memory-utilization 0.75 \
  --enforce-eager
```

That is the same command as `~/projects/jalgo/vllm_serve_qwen8.sh`. After the files are on disk, either keep using it or switch back to the offline command in `README.md`.
