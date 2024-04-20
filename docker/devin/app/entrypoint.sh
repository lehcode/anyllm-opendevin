#!/bin/bash --login

eval "$(conda shell.bash activate "${VENV_NAME}")"

if [ -n "${DEBUG}" ]; then
    printf "******\n* System information: \n******"
    echo "Python executable in ${VENV_NAME}: $(which python3) v$(python3 --version)"
    echo "Anaconda environments info:"
    conda info --envs
    echo "Anaconda packages sources: $(conda config --show-sources)"
    echo "PYTHONPATH: $(env | grep PYTHONPATH)"
    env | grep LITELLM_PORT
    env | grep JUPYTER_PORT
    echo "Nvidia CUDA properties:"
    nvidia-smi
    echo "Working directory: $(pwd)" 
    ls -al ./run
    bash ./run/env_debug
fi

set -eux

python3 opendevin/download.py # No-op to download assets

# Start API server
if [ -n "${DEBUG}" ]; then
    python3 -Xfrozen_modules=off ./run/devin_up --port "${DEVIN_API_PORT}" --logging debug --reload
else
    python3 ./run/devin_up --port "${DEVIN_API_PORT}" --logging critical --reload
fi

