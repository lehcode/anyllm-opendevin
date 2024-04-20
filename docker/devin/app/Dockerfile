ARG cuda_version=12.4.0
ARG ubuntu_tag=ubuntu20.04
ARG tag="${cuda_version}-devel-${ubuntu_tag}"
FROM nvidia/cuda:${tag} as build-app
ARG cuda_version
ARG ubuntu_version=Ubuntu-20.04

LABEL org.opencontainers.image.description="Devin with Nvidia CUDA v${cuda_version} and Miniconda3"
LABEL org.opencontainers.image.author="lehcode <53556648+lehcode@users.noreply.github.com>"

ARG debug
ARG apt_cache_dir=/var/cache/apt
ARG nvidia_utils_driver

ENV DEBUG="$debug"
ENV DEBIAN_FRONTEND=noninteractive

RUN --mount=type=cache,target=${apt_cache_dir},sharing=locked \
    if [ -n "${DEBUG}" ]; then set -eux; fi && \
    echo "Updating $ubuntu_version packages..." && \
    apt-get -q update  && \
    apt-get install -qy --no-install-recommends \
    tzdata locales cpanminus curl git gnupg gnupg2 gnupg1 wget \
    nvidia-utils-${nvidia_utils_driver}  && \
    if [ -z "${DEBUG}" ]; then apt-get -qy upgrade ; fi

#ADD https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin /tmp/
#ADD https://developer.download.nvidia.com/compute/cuda/12.4.1/local_installers/cuda-repo-wsl-ubuntu-12-4-local_12.4.1-1_amd64.deb /tmp/
#
#RUN --mount=type=cache,target=${apt_cache_dir},sharing=locked \
#    if [ -n "${DEBUG}" ]; then set -eux; fi && \
#    mv /tmp/cuda-wsl-ubuntu.pin /etc/apt/preferences.d/ && \
#    dpkg -i /tmp/cuda-repo-wsl-ubuntu-12-4-local_12.4.1-1_amd64.deb && \
#    cp /var/cuda-repo-wsl-ubuntu-12-4-local/cuda-*-keyring.gpg /usr/share/keyrings/ && \
#    apt-get update && \
#    apt-get -y install cuda-toolkit-12-4

ARG timezone=Etc/UTC
ARG locale

ENV LANG="$locale"
ENV TZ="$timezone"

ADD docker/locales /etc/locale.gen

RUN --mount=type=cache,target=${apt_cache_dir},sharing=locked \
    echo "Configuring timezone and $ubuntu_version locale..." && \
    if [ -n "$debug" ]; then set -eux; fi && \
    ln -fs "/usr/share/zoneinfo/$timezone" /etc/localtime && \
    echo "$TZ" | tee -pa /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata locales

RUN --mount=type=cache,target=${apt_cache_dir},sharing=locked \
    echo "System upgrade..." && \
    if [ -n "$debug" ]; then set -eux; fi && \    
    apt-get -q update && apt-get -qy upgrade && \
    rm -f /usr/lib/x86_64-linux-gnu/libcudadebugger.so.1 && \
    rm -f /usr/lib/x86_64-linux-gnu/libnvidia-ml.so.1 && \
    rm -f /usr/lib/x86_64-linux-gnu/libcuda.so.1 && \
    if [ -z "$debug" ]; then rm -rf /var/lib/apt/lists/*; fi

ADD --checksum=sha256:4da8dde69eca0d9bc31420349a204851bfa2a1c87aeb87fe0c05517797edaac4 https://repo.anaconda.com/miniconda/Miniconda3-py311_24.3.0-0-Linux-x86_64.sh /tmp/miniconda.sh

ARG conda_root=/var/miniconda3
ARG venv_name
ARG app_root

ENV CONDA_ROOT=$conda_root
ENV VENV_NAME="$venv_name"
ENV APP_ROOT="$app_root"
ARG conda_pkgs_dir="$conda_root/pkgs"

RUN --mount=type=cache,target=${conda_pkgs_dir},sharing=locked \
    if [ -n "${DEBUG}" ]; then set -eux; fi && \
    echo "Installing Miniconda..." && \
    mkdir -p "${CONDA_ROOT}" && \
    bash /tmp/miniconda.sh -b -u -p ${CONDA_ROOT}
#    sed -i "s/<CONDA_DIR>/$(echo "${CONDA_ROOT}/envs/${VENV_NAME}" | sed -e 's/[\/&]/\\&/g')/g" /tmp/environment.yml   && \
#    sed -i "s/<VENV_NAME>/${VENV_NAME}/g" /tmp/environment.yml 

ENV PATH="/root/.local/bin:${CONDA_ROOT}/bin:${PATH}"
ARG conda_pkgs_dir=$CONDA_ROOT/pkgs

#COPY docker/devin/app/.condarc "${CONDA_ROOT}/.condarc"

RUN --mount=type=cache,target=${conda_pkgs_dir},sharing=locked \
    if [ -n "${DEBUG}" ]; then set -eux; fi && \
    conda install -qy pip   && \
    conda init bash   && \
    echo "Configuring ${VENV_NAME} environment..." && \
    conda create -qy -n "${VENV_NAME}" python=3.12

RUN --mount=type=cache,target=${conda_pkgs_dir},sharing=locked \
    if [ -n "${DEBUG}" ]; then set -eux; fi && \
    conda install -qy -n "${VENV_NAME}" pip

ARG bin_dir=/usr/local/bin

# ENV PYTHONPATH="${APP_ROOT}"
ENV BIN_DIR="$bin_dir"

# Activate Miniconda environment
RUN eval "$(conda shell.bash activate "${VENV_NAME}")"
# Make RUN commands use the new environment
SHELL ["conda", "run", "-n", "od_env", "/bin/bash", "-c"]

RUN --mount=type=cache,target=${conda_pkgs_dir},sharing=locked \
    if [ -n "$debug" ]; then set -eux; fi && \
    echo "Setting up Miniconda..." && \
    conda config -q --add channels anaconda  && \
    conda config -q --add channels pytorch  && \
    conda config -q --add channels microsoft  && \
    conda config -q --set channel_priority disabled

RUN --mount=type=cache,target=${conda_pkgs_dir},sharing=locked \
    if [ -n "$debug" ]; then set -eux; fi && \
    echo "Installing Jupyter Notebook..." && \
    if [ -n "$debug" ]; then set -eux; fi && \
    conda install -qy jupyter 

RUN --mount=type=cache,target=${conda_pkgs_dir},sharing=locked \
    if [ -n "$debug" ]; then set -eux; fi && \
    echo "Dumping ${VENV_NAME} environment config..." && \
    if [ -n "$debug" ]; then set -eux; fi && \
    conda env export -q -n "${VENV_NAME}" -f environment.yml

WORKDIR "$APP_ROOT"

COPY agenthub agenthub
COPY dev_config dev_config
COPY evaluation evaluation
COPY opendevin opendevin
COPY tests tests
COPY pyproject.toml .
# COPY poetry.lock .

# ENV POETRY_HOME=/etc/poetry
# ENV PATH="${POETRY_HOME}/bin:${PATH}"
# ENV POETRY_CACHE_DIR=/root/.cache/pypoetry
# ENV POETRY_NO_INTERACTION=1
# ENV POETRY_CACHE_DIR=/root/poetry_cache
# # If you do not want to install the current project use --no-root.
# # If you want to use Poetry only for dependency management but not for packaging, you can disable package mode by
# # setting package-mode = false in your pyproject.toml file.
# # In a future version of Poetry this warning will become an error!
# RUN --mount=type=cache,target=${POETRY_CACHE_DIR} \
#     if [ -n "$debug" ]; then set -eux; fi && \
#     curl -sSL "https://install.python-poetry.org" | python3 -  && poetry --version && \
#     echo "Building OpenDevin..." && \
#     poetry install --without evaluation --no-root && \
#     if [ -z "${debug}" ]; then rm -rf $POETRY_CACHE_DIR; fi

#ARG litellm_port=11111
#ARG jupyter_port=37799

#COPY dev_config/python/.pre-commit-config.yaml /tmp/
COPY .git .git
COPY .gitignore .
COPY .gitattributes .
COPY docker/devin/app/devin_up.py oppendevin_launcher
COPY docker/env_debug.sh "${APP_ROOT}/run/env_debug"
COPY docker/devin/app/entrypoint.sh "${APP_ROOT}/docker-entrypoint.sh"

RUN --mount=type=cache,target=${conda_pkgs_dir},sharing=locked \
    if [ -n "$debug" ]; then set -eux; fi && \
    if [ -n "${DEBUG}" ]; then conda run -n ${VENV_NAME} pip install debugpy; fi

RUN python3 opendevin/download.py # No-op to download assets

RUN --mount=type=cache,target=${conda_pkgs_dir},sharing=locked \
    if [ -n "$debug" ]; then set -eux; fi && \
    echo "Finalizing build..." && \
#    git config --unset-all core.hooksPath || true  && \
#    poetry run pre-commit install --config /tmp/.pre-commit-config.yaml && \
    chmod a+x ${APP_ROOT}/docker-entrypoint.sh && \
    rm -rf /var/lib/apt/lists/*

ARG devin_ws_port
ARG jupyter_port
ARG workspace_dir

COPY .env .

ENV WORKSPACE_DIR=$workspace_dir

EXPOSE $devin_ws_port
EXPOSE $jupyter_port

ENTRYPOINT ["/docker-entrypoint.sh", "-c"]
CMD "-m ${DEFAULT_CHAT_MODEL} -e ${DEFAULT_EMBEDDINGS_MODEL} --"
