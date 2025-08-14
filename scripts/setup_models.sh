#!/usr/bin/env bash
set -e

mkdir -p models

# Modelo por defecto (rápido y liviano en CPU):
# TinyLlama-1.1B-Chat en GGUF Q4_K_M
if [ ! -f models/tinyllama-1.1b-chat.Q4_K_M.gguf ]; then
  echo "Descargando TinyLlama 1.1B Chat (GGUF Q4_K_M)..."
  curl -L -o models/tinyllama-1.1b-chat.Q4_K_M.gguf \    https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat.Q4_K_M.gguf
fi

echo "Modelos listos. Puedes cambiar LLAMA_MODEL_PATH en .env si usas otro modelo."
