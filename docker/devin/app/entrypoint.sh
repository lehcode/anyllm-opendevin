#!/bin/bash --login

eval "$(conda shell.bash activate "${VENV_NAME}")"

if [ -n "${DEBUG}" ]; then
    echo "Python executable in ${VENV_NAME}': $(which python3) v$(python3 --version)"

    echo "Conda environments info:"
    conda info --envs

    env | grep PYTHONPATH

    echo "Nvidia CUDA properties:"
    nvidia-smi

    pwd
fi

set -eux

# Start API server
if [ -n "${DEBUG}" ]; then
    python3 run_api.py --port ${APP_PORT} --host ${APP_HOST} --reload --log-level info
else
    python3 run_api.py --port ${APP_PORT} --host ${APP_HOST} --reload --log-level crit
fi

