#!/usr/bin/env bash

if [ -n "${DEBUG}" ]; then
    set -eu
    echo "Debugging is enabled"
    echo "Container hostname: $(hostname)"
    echo "Container IP: $(hostname -i)"
    echo "Environment variables:"
    env
    echo "Python environment and executables status:"
    if [ -f "${BIN_DIR}/env_debug" ]; then /bin/sh < "${BIN_DIR}/env_debug"; fi
    echo "Nvidia CUDA properties:"
    nvidia-smi
    echo "Force-loading the default Ollama model:"
fi

# Process named arguments
while getopts ":-m:e:" opt; do
  case ${opt} in
    -m ) chat_model="$OPTARG";;
    -e ) embeddings_model="$OPTARG";;
    \? ) echo "Invalid option: $OPTARG" 1>&2; exit 1;;
    : ) echo "Invalid option: $OPTARG requires an argument" 1>&2; exit 1;;
  esac
done
shift $((OPTIND -1))

python3 "/usr/local/bin/configure_devin" "$chat_model" "$embeddings_model"

python3 "./opendevin/sandbox/sandbox.py" -d "${WORKSPACE_DIR}"

python3 -m uvicorn opendevin.server.listen:app --reload --port 3000 --host 172.28.111.5
