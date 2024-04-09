#!/bin/bash

echo "Container hostname: $(hostname)"
echo "Container IP: $(hostname -i)"
echo "Environment variables:"
env

echo "Python environment and executables status:"
python3 --version
echo "Python executable: $(which python3)/$(python3 --version)"
echo "PIP executable: $(which pip)/$(pip --version)"
echo "Python executable in ${VENV_NAME}: $(conda run -n ${VENV_NAME} python3 --version)"
echo "Python executable in ${VENV_NAME}: $(conda run -n ${VENV_NAME} pip --version)"

echo "Nvidia CUDA properties:"
nvidia-smi

echo "Conda environments info:"
conda info --envs
