# Deploying Waypoint Server on Cloud GPU

This guide covers deploying the Waypoint world model server on RunPod or Vast.ai so your web app can connect to it.

## Requirements

- Cloud GPU with at least 16GB VRAM (RTX 3090, RTX 4090, A10, A100)
- HuggingFace account with access token
- ~20GB disk space for model weights

---

## Option 1: RunPod (Recommended - Easiest)

### Step 1: Create RunPod Account
1. Go to https://runpod.io
2. Sign up and add credits ($10-20 is enough to start)

### Step 2: Launch a GPU Pod
1. Click "Deploy" → "GPU Pods"
2. Select a GPU:
   - **Budget:** RTX 3090 (~$0.20/hr)
   - **Better:** RTX 4090 (~$0.35/hr)
   - **Best:** A100 (~$1.00/hr)
3. Select template: **RunPod Pytorch 2.1** (or any CUDA template)
4. Set volume: **20GB** minimum
5. Click "Deploy"

### Step 3: Connect to Pod
1. Once running, click "Connect"
2. Choose "Web Terminal" or use SSH

### Step 4: Setup Server
Run these commands in the terminal:

```bash
# Set HuggingFace token (get from https://huggingface.co/settings/tokens)
export HF_TOKEN="hf_your_token_here"

# Install dependencies
pip install \
  --index-url https://download.pytorch.org/whl/cu121 \
  --extra-index-url https://pypi.org/simple \
  torch torchvision

pip install fastapi uvicorn pillow

pip install "world_engine @ git+https://github.com/Overworldai/world_engine.git"

# Download the server script
curl -O https://raw.githubusercontent.com/Overworldai/Biome/main/src-tauri/server-components/server.py

# Run the server
python server.py --host 0.0.0.0 --port 7987
```

### Step 5: Get Your Server URL
1. In RunPod dashboard, find your pod's **Public IP** or **Proxy URL**
2. Your WebSocket URL will be: `ws://<public-ip>:7987/ws`

### Step 6: Connect Your Web App
1. Open http://localhost:3000 (your brain-game)
2. Enter: `ws://<runpod-ip>:7987/ws`
3. Click Connect

---

## Option 2: Vast.ai (Cheapest)

### Step 1: Create Vast.ai Account
1. Go to https://vast.ai
2. Sign up and add credits

### Step 2: Find a Machine
1. Go to "Search" tab
2. Filter:
   - GPU RAM: >= 16GB
   - CUDA: >= 12.0
   - Internet Up: >= 100 Mbps
3. Sort by price ($/hr)
4. Select a machine and click "Rent"

### Step 3: Configure Instance
1. Select image: `pytorch/pytorch:2.1.0-cuda12.1-cudnn8-runtime`
2. Disk: 30GB
3. Check "Direct SSH" for port access
4. Launch

### Step 4: Connect and Setup
```bash
# SSH into your instance (Vast.ai provides the command)
ssh -p <port> root@<ip> -L 7987:localhost:7987

# Inside the instance:
export HF_TOKEN="hf_your_token_here"

pip install fastapi uvicorn pillow
pip install "world_engine @ git+https://github.com/Overworldai/world_engine.git"

curl -O https://raw.githubusercontent.com/Overworldai/Biome/main/src-tauri/server-components/server.py

python server.py --host 0.0.0.0 --port 7987
```

### Step 5: Port Forwarding
Vast.ai doesn't always expose ports directly. Use SSH tunnel:
```bash
# On your local machine:
ssh -p <vast-port> root@<vast-ip> -L 7987:localhost:7987
```
Then connect to: `ws://localhost:7987/ws`

---

## Option 3: Lambda Labs (Most Reliable)

### Step 1: Create Account
1. Go to https://lambdalabs.com/cloud
2. Sign up (may have waitlist)

### Step 2: Launch Instance
1. Select GPU (A10 or A100)
2. Launch with Ubuntu + CUDA

### Step 3: Setup (same as above)
```bash
export HF_TOKEN="hf_your_token_here"
pip install fastapi uvicorn pillow
pip install "world_engine @ git+https://github.com/Overworldai/world_engine.git"
curl -O https://raw.githubusercontent.com/Overworldai/Biome/main/src-tauri/server-components/server.py
python server.py --host 0.0.0.0 --port 7987
```

---

## Quick Setup Script

Save this as `setup.sh` and run on any cloud GPU:

```bash
#!/bin/bash
set -e

echo "=== Waypoint Server Setup ==="

# Check for HF_TOKEN
if [ -z "$HF_TOKEN" ]; then
    echo "ERROR: Set HF_TOKEN first:"
    echo "  export HF_TOKEN='hf_your_token'"
    exit 1
fi

# Install PyTorch with CUDA
echo "Installing PyTorch..."
pip install --quiet \
  --index-url https://download.pytorch.org/whl/cu121 \
  --extra-index-url https://pypi.org/simple \
  torch torchvision

# Install dependencies
echo "Installing dependencies..."
pip install --quiet fastapi uvicorn pillow

# Install world_engine
echo "Installing world_engine..."
pip install --quiet "world_engine @ git+https://github.com/Overworldai/world_engine.git"

# Download server
echo "Downloading server.py..."
curl -sO https://raw.githubusercontent.com/Overworldai/Biome/main/src-tauri/server-components/server.py

echo ""
echo "=== Setup Complete ==="
echo "Run: python server.py --host 0.0.0.0 --port 7987"
echo ""
```

---

## Troubleshooting

### "CUDA out of memory"
- Use a GPU with more VRAM (24GB+ recommended)
- Or use quantization: edit server.py line 71 to `QUANT = "w8a8"`

### "Model not found" or 401 error
- Check your HF_TOKEN is set correctly
- Make sure you've accepted model terms on HuggingFace

### Connection refused
- Check firewall allows port 7987
- On RunPod: use the proxy URL instead of direct IP
- On Vast.ai: use SSH tunnel

### Slow generation (>200ms/frame)
- Use a faster GPU (A100 > A10 > RTX 4090 > RTX 3090)
- Enable quantization for speed boost

---

## Cost Estimates

| GPU | Cost/hr | Performance |
|-----|---------|-------------|
| RTX 3090 | $0.20 | ~80ms/frame |
| RTX 4090 | $0.35 | ~50ms/frame |
| A10 | $0.50 | ~60ms/frame |
| A100 | $1.00 | ~30ms/frame |

**For testing:** RTX 3090 at $0.20/hr = $4.80/day

---

## Keeping Server Running

Use `screen` or `tmux` to keep server running after disconnect:

```bash
# Start a screen session
screen -S waypoint

# Run server
python server.py --host 0.0.0.0 --port 7987

# Detach: Ctrl+A, then D
# Reattach later: screen -r waypoint
```

---

## Security Note

This setup exposes your server publicly. For production:
1. Add authentication to server.py
2. Use HTTPS/WSS with SSL certificates
3. Restrict IP access via firewall
