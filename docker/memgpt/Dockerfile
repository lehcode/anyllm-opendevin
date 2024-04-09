ARG cuda_version="11.3.1"
ARG locale="en_US.UTF-8"
FROM nvidia/cuda:${cuda_version}-devel-ubuntu20.04 as build

LABEL org.opencontainers.image.description="MemGPT image with NVidia CUDA v$cuda_version"
LABEL org.opencontainers.image.cuda_version=$cuda_version

ARG conda_dir=/root/miniconda3
ARG debug
ARG venv_name
ARG timezone=Etc/UTC
ARG bin_dir=/usr/local/bin
ARG conda_cache_dir
ARG pip_cache_dir
ARG memgpt_config_file=/etc/memgpt/config.json

ENV PATH=${PATH}:/root/.local/bin:"$conda_dir/bin"
ENV LITELLM_PORT="$litellm_port"
ENV DEBUG="$debug"
ENV VENV_NAME="$venv_name"
ENV CONDA_DIR="$conda_dir"
ENV TZ="$timezone"
ENV DEBIAN_FRONTEND=noninteractive
ENV BIN_DIR="$bin_dir"
ENV MEMGPT_CONFIG_FILE="$memgpt_config_file"

WORKDIR /root

COPY docker/memgpt/environment.base.tmpl.yml environment.yml
ADD https://repo.anaconda.com/miniconda/Miniconda3-py311_24.1.2-0-Linux-x86_64.sh /tmp/miniconda.sh

RUN --mount=type=cache,target=/var/cache/apt \
    if [ -n "$debug" ]; then set -eux; fi && \
    apt-get -q update && \
    apt-get install -qy --no-install-recommends \
      tzdata locales cpanminus curl git gnupg gnupg2 gnupg1 && \
    if [ -z "$debug" ]; then apt-get -qy upgrade; fi

RUN if [ -n "$debug" ]; then set -eux; fi && \
    bash /tmp/miniconda.sh -b -u -p ${CONDA_DIR} && \
    sed -i "s/<CONDA_DIR>/$(echo "$conda_dir" | sed -e 's/[\/&]/\\&/g')/g" environment.yml && \
    sed -i "s/<VENV_NAME>/$venv_name/g" environment.yml

RUN --mount=type=cache,target=$conda_cache_dir \
    conda config --set channel_priority disabled && \
    conda config --add channels conda && \
    conda config --add channels conda-forge && \
    conda init -q bash && \
    conda env create -y -f environment.yml -n "$venv_name"

RUN --mount=type=cache,target=$conda_cache_dir \
    eval "$(conda shell.bash activate $venv_name)" && \
    conda install pip

WORKDIR /usr/local/src/memgpt

RUN --mount=type=cache,target=$pip_cache_dir \
    if [ ! -z "$debug" ]; then set -eux; fi && \
    git clone https://github.com/cpacker/MemGPT.git . && \
    conda run -n "$venv_name" pip install -e . && \
    conda run -n "$venv_name" pip install -e '.[local]'

RUN --mount=type=cache,target=/var/cache/apt \
    if [ ! -z "$debug" ]; then set -eux; fi && \
    ln -fs /usr/share/zoneinfo/$timezone /etc/localtime && \
    echo $timezone > /etc/timezone && cat /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get -q update

SHELL ["conda", "run", "-n", "od_env", "/bin/bash", "-c"]

COPY docker/env_debug.sh "$bin_dir/env_debug"
COPY docker/memgpt/.condarc "$CONDA_DIR/.condarc"
COPY docker/memgpt/memgpt_config "$MEMGPT_CONFIG_FILE"
COPY docker/memgpt/entrypoint.sh /opt/nvidia/nvidia_entrypoint.sh
