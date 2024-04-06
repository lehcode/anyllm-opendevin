#!/usr/bin/env bash

[[ -z ${DEBUG} ]] || python3 --version
[[ -z ${DEBUG} ]] || which python3
[[ -z ${DEBUG} ]] || which pip
[[ -z ${DEBUG} ]] || conda run -n ${VENV_NAME} which python3
[[ -z ${DEBUG} ]] || conda run -n ${VENV_NAME} which pip
