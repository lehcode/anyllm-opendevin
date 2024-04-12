#!/bin/bash --login

eval "$(conda shell.bash activate "${VENV_NAME}")"

if [ -n "${DEBUG}" ]; then
    set -eux
    echo "Python executable in '${VENV_NAME}': $(python3 --version)"
    echo "Conda environments info:"
    conda info --envs
    echo "Nvidia CUDA properties:"
    nvidia-smi
fi

python3 -m uvicorn opendevin.server.listen:app --reload --port "${APP_PORT}" --host "${APP_HOST}"
