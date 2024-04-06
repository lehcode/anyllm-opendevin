#!/usr/bin/env bash

[[ ! -z "${DEBUG}" ]]; set -eux
[[ -f /usr/bin/env_debug ]] && chmod a+x /usr/bin/env_debug

[[ -z ${DEBUG} ]] || pwd
[[ -z ${DEBUG} ]] || env
[[ -z ${DEBUG} ]] || python3 --version
[[ -z ${DEBUG} ]] || which python3

# pipenv --python /usr/local/miniconda3/bin/python3

# read -p "Please enter your desired LLM model name: " llm_model

# conda run -n "${VENV_NAME}" pip install chromadb

# conda install -y -n ${VENV_NAME} uvicorn

conda run -n "${VENV_NAME}"  uvicorn opendevin.server.listen:app --reload --port 3000 --host 172.28.111.5

#python3 "${APP_DIR}/opendevin/sandbox/sandbox.py" -d "${WORKSPACE_DIR}"
