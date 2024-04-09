#!/usr/bin/env bash

if [ ! -d "$conda_dir/envs/$venv_name" ]; then
    bash /tmp/miniconda.sh -b -u -p ${CONDA_DIR};
fi
sed -i "s/<CONDA_DIR>/$(echo "$conda_dir" | sed -e 's/[\/&]/\\&/g')/g" environment.yml
sed -i "s/<VENV_NAME>/$venv_name/g" environment.yml
