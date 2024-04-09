ARG cuda_version=11.3.1
ARG cuda_base_image=ubuntu:20.04
FROM ${cuda_base_image} as build

LABEL org.opencontainers.image.description="Devin with Nvidia CUDA v${cuda_version} and Miniconda3"

ARG venv_name
ARG app_dir
ARG debug
ARG workspace_dir
ARG conda_dir=/root/miniconda3
ARG timezone=Etc/UTC
ARG bin_dir=/usr/local/bin

ENV VENV_NAME="$venv_name"
ENV VENV_DIR="$conda_dir/envs/$venv_name"
ENV WORKSPACE_DIR="$workspace_dir"
ENV DEBUG="$debug"
ENV PATH="${PATH}:$conda_dir/bin"
ENV APP_DIR="$app_dir"
ENV CONDA_DIR="$conda_dir"
ENV TZ="$timezone"
ENV BIN_DIR="$bin_dir"

WORKDIR /root

COPY docker/devin/app/environment.base.tmpl.yml .
ADD https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh /tmp/miniconda.sh
COPY docker/env_debug.sh .

RUN --mount=type=cache,target=/var/cache/apt \
    if [ -n "$debug" ]; then set -eux; fi && \
    apt-get -q update && \
    apt-get install -qy --no-install-recommends tzdata locales cpanminus && \
    if [ -z "$debug" ]; then apt-get -qy upgrade; fi && \
    ln -fs /usr/share/zoneinfo/$timezone /etc/localtime && \
    echo $timezone > /etc/timezone && cat /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt -q update && if [ -z "$debug" ]; then apt -qy upgrade; fi && \
    apt-get install -qy --no-install-recommends ca-certificates git gnupg gnupg2 gnupg1 && \
    if [ -z "$debug" ]; then rm -rf /var/lib/apt/lists/*; fi

RUN if [ ! -d "$conda_dir/envs/$venv_name" ]; then bash /tmp/miniconda.sh -b -u -p ${CONDA_DIR}; fi && \
    sed -i "s/<CONDA_DIR>/$(echo "$conda_dir" | sed -e 's/[\/&]/\\&/g')/g" environment.yml && \
    sed -i "s/<VENV_NAME>/$venv_name/g" environment.yml

ADD "https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin" "/tmp/cuda-ubuntu2004.pin"
ADD "https://developer.download.nvidia.com/compute/cuda/11.3.1/local_installers/cuda-repo-ubuntu2004-11-3-local_11.3.1-465.19.01-1_amd64.deb" "/tmp/cuda-repo-ubuntu2004-11-3-local_11.3.1-465.19.01-1_amd64.deb"
ADD "https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub" "/etc/apt/7fa2af80.pub"

ENV DEBIAN_FRONTEND=noninteractive

RUN --mount=type=cache,target=/var/cache/apt \
    cat /etc/apt/7fa2af80.pub | apt-key add - && \
    dpkg -i /tmp/cuda-repo-ubuntu2004-11-3-local_11.3.1-465.19.01-1_amd64.deb && \
    apt-get update && apt-get -y install --no-install-recommends cuda && \
    if [ -z "$debug" ]; then apt clean; fi && \
    if [ -z "$debug" ]; then rm -rf /var/lib/apt/lists/*; fi && \
    # See https://forums.developer.nvidia.com/t/wsl-modulus-docker-run-error-libnvidia-ml-so-1-file-exists-unknown/256058/7
    rm -rf /usr/lib/x86_64-linux-gnu/libcuda.so* \
      /usr/lib/x86_64-linux-gnu/libnvcuvid.so* \
      /usr/lib/x86_64-linux-gnu/libnvidia-*.so* \
      /usr/local/cuda/compat/lib/*.465.19.01

RUN --mount=type=cache,target=/root/.cache/pip \
    if [ ! -z "$debug" ]; then set -eux; fi && \
    pip install -q --upgrade pip

COPY ./docker/devin/app/.condarc /root/

RUN --mount=type=cache,target=/root/anaconda/pkgs \
    conda config --set channel_priority disabled && \
    conda config --prepend channels conda && \
    conda config --prepend channels conda-forge && \
    conda init -q bash && \
    conda env create -y -f environment.yml -n "$venv_name"

ENV PATH=${PATH}:/root/.local/bin
WORKDIR /usr/local/src/chromadb

WORKDIR ${APP_DIR}
COPY requirements.txt .

RUN --mount=type=cache,target=/root/.cache/pip \
    if [ ! -z "$debug" ]; then set -eux; fi && \
    conda install -y -n "$venv_name" pip && \
    conda run -n "$venv_name" pip install -r requirements.txt

WORKDIR /usr/local/src/chromadb

RUN --mount=type=cache,target=/root/.cache/pip \
    conda run -n "$venv_name" pip install uvicorn && \
    git clone https://github.com/chroma-core/chroma.git . && \
    conda run -n "$venv_name" pip install -r requirements.txt && \
    conda run -n "$venv_name" pip install .

# Make RUN commands use the new environment
SHELL ["conda", "run", "-n", "od_env", "/bin/bash", "-c"]

COPY docker/devin/app/entrypoint.sh "$bin_dir/entrypoint.sh"
COPY docker/devin/app/configure.py /usr/local/bin/configure_devin

