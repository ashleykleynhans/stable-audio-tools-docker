#!/usr/bin/env bash

export HF_HOME="/workspace"
VENV_PATH=$(cat /workspace/stable-audio-tools/venv_path)
source ${VENV_PATH}/bin/activate
cd /workspace/stable-audio-tools
echo "Starting stable-audio-tools"
export GRADIO_SERVER_NAME="0.0.0.0"
export GRADIO_SERVER_PORT="3001"
nohup python3 run_gradio.py > /workspace/logs/stable-audio-tools.log 2>&1 &
echo "stable-audio-tools started"
echo "Log file: /workspace/logs/stable-audio-tools.log"
deactivate
