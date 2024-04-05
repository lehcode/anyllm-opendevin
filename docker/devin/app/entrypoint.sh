#!/usr/bin/env bash

[[ ! -z "${DEBUG}" ]]; set -eux

[[ -z ${DEBUG} ]] || pwd
[[ -z ${DEBUG} ]] || python3 --version
[[ -z ${DEBUG} ]] || which python3
# [[ -z ${DEBUG} ]] || apt install -y tree && tree -L 2

pipenv --python /usr/local/miniconda3/bin/python3

python3 -m pip install --upgrade pip
python3 -m pip install playwright

uvicorn opendevin.server.listen:app --reload --port 3000 --host 172.28.111.5
# make start-backend

#python3 "${APP_DIR}/opendevin/sandbox/sandbox.py" -d "${WORKSPACE_DIR}"
