#!/usr/bin/env bash

export HF_HOME="/workspace"
source /venv/bin/activate
cd /workspace/stable-audio-tools
echo "Starting stable-audio-tools"
export PYTHONUNBUFFERED=1
export GRADIO_SERVER_NAME="0.0.0.0"
export GRADIO_SERVER_PORT="3001"
nohup python3 run_gradio.py \
    --model-config /workspace/stable-audio-tools/ckpt/model_config.json \
    --ckpt-path /workspace/stable-audio-tools/ckpt/model.safetensors > /workspace/logs/stable-audio-tools.log 2>&1 &
echo "stable-audio-tools started"
echo "Log file: /workspace/logs/stable-audio-tools.log"
deactivate
