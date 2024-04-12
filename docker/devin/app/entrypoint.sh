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

    ls -al .
fi

set -eux

# Start API server
python3 run_api.py --port ${APP_PORT} --host ${APP_HOST} --reload --log-level debug

