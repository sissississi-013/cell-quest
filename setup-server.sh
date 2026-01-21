#!/bin/bash
# Waypoint Server Quick Setup Script
# Run this on any cloud GPU (RunPod, Vast.ai, Lambda Labs)

set -e

echo "============================================"
echo "  Waypoint World Model Server Setup"
echo "============================================"
echo ""

# Check for HF_TOKEN
if [ -z "$HF_TOKEN" ]; then
    echo "ERROR: HuggingFace token not set!"
    echo ""
    echo "Get your token from: https://huggingface.co/settings/tokens"
    echo "Then run:"
    echo "  export HF_TOKEN='hf_your_token_here'"
    echo "  ./setup-server.sh"
    echo ""
    exit 1
fi

echo "[1/5] HuggingFace token found"

# Install PyTorch
echo "[2/5] Installing PyTorch with CUDA..."
pip install --quiet --upgrade \
  --index-url https://download.pytorch.org/whl/cu121 \
  --extra-index-url https://pypi.org/simple \
  torch torchvision

# Install server dependencies
echo "[3/5] Installing server dependencies..."
pip install --quiet fastapi uvicorn pillow transformers safetensors

# Install world_engine
echo "[4/5] Installing world_engine (this may take a few minutes)..."
pip install --quiet \
  --index-url https://download.pytorch.org/whl/test/cu128 \
  --extra-index-url https://download.pytorch.org/whl/nightly/cu128 \
  --extra-index-url https://pypi.org/simple \
  --upgrade --ignore-installed \
  "world_engine @ git+https://github.com/Overworldai/world_engine.git"

# Download server script
echo "[5/5] Downloading server.py..."
curl -sO https://raw.githubusercontent.com/Overworldai/Biome/main/src-tauri/server-components/server.py

echo ""
echo "============================================"
echo "  Setup Complete!"
echo "============================================"
echo ""
echo "To start the server, run:"
echo "  python server.py --host 0.0.0.0 --port 7987"
echo ""
echo "Your WebSocket URL will be:"
echo "  ws://<your-server-ip>:7987/ws"
echo ""
echo "First startup will download the model (~5GB)"
echo "and compile CUDA graphs (takes 1-2 minutes)."
echo ""
