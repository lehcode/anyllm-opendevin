#!/usr/bin/env bash

[[ ! -z "${DEBUG}" ]]; set -eux

# curl -X POST http://ollama:11434/api/pull -d '{"name": "ollama/mistral:7b"}'
# curl http://ollama:11434/api/tags

# to preload a model and leave it in memory
# curl http://ollama:11434/api/generate -d '{"model": "llama2", "keep_alive": -1}'
# To unload the model and free up memory
# curl http://ollama:11434/api/generate -d '{"model": "llama2", "keep_alive": -1}'

conda run -n "${VENV_NAME}" memgpt quickstart --backend memgpt

conda run -n "${VENV_NAME}" memgpt run \
    --agent memgpt_agent \
    --model ollama/mistral:7b \
    --model-endpoint-type ollama \
    --model-endpoint http://ollama:11434 \
    --model-wrapper airoboros-l2-70b-2.1 \
    --debug
