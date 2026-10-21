# Set up PyTorch and vLLM on the DGX

This is the one-time install on the DGX Spark box (`shaun@192.168.0.140`, NVIDIA GB10). Serving Qwen3-8B is in `README.md`.

The working environment is already installed:

| Piece | Version |
| --- | --- |
| Python | 3.12.3 |
| venv | `~/vllm-env` |
| PyTorch | 2.11.0+cu130 (CUDA 13.0) |
| vLLM | 0.23.0 |

PyTorch is not installed by itself. `pip install vllm` pulls `torch`, `torchaudio`, and `torchvision`, plus the CUDA 13 libraries (`nvidia-cudnn-cu13`, NCCL, and the rest). A separate `pip install torch` from an older CUDA wheel (cu124 or cu128) will not match this GPU.

## Connect

From this Mac, in this folder:

```bash
./enter.sh
```

## Install

On the DGX, use a venv that contains only vLLM. `~/torch-env` and `~/sglang-env` are separate and should stay that way. Mixing sglang and flash-attn into the vLLM env broke torch compile.

```bash
sudo apt install -y python3.12-dev build-essential gcc g++ make

python3 -m venv ~/vllm-env
source ~/vllm-env/bin/activate
pip install --upgrade pip setuptools wheel
pip install vllm
```

`python3.12-dev` and the compilers are there because some vLLM dependencies build native extensions. `~/projects/jalgo/vllm_activate.sh` is only `source ~/vllm-env/bin/activate`.

## Check

```bash
source ~/vllm-env/bin/activate
python -c "import torch, vllm; print(torch.__version__, torch.version.cuda, torch.cuda.is_available(), torch.cuda.get_device_name(0), vllm.__version__)"
```

Expected output:

```text
2.11.0+cu130 13.0 True NVIDIA GB10 0.23.0
```

`nvidia-smi` should show the GB10 before you start a server. `torch.cuda.is_available()` must be `True`. If it is `False`, the venv is not the one above, or the driver is not visible in that shell.

## If compile cache gets stuck

This showed up when sglang and flash-attn had been installed in the same environment as vLLM. Clear the caches and stay in `~/vllm-env`:

```bash
rm -rf ~/.cache/vllm/torch_compile_cache /tmp/torchinductor_shaun
```

Do not `pip install` sglang or flash-attn into `~/vllm-env`. The current serve command uses `--enforce-eager`, which turns torch.compile and CUDA graphs off.

## Next

Activate the venv and follow `README.md` to start the server from the local Qwen3-8B snapshot.
