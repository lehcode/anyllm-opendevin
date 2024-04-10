ARG cuda_version=12.4.0
ARG ubuntu_tag=ubuntu20.04
ARG tag="${cuda_version}-devel-${ubuntu_tag}"
FROM nvidia/cuda:${tag} as build
ARG cuda_version
ARG ubuntu_version

LABEL org.opencontainers.image.description="Devin with Nvidia CUDA v${cuda_version} and Miniconda3"

ARG timezone=Etc/UTC
ARG venv_name=conda_env
ARG app_dir=/root/devin
ARG debug
ARG workspace_dir
ARG bin_dir=/usr/local/bin
ARG pip_cache_dir=/root/.cache/pip
ARG apt_cache_dir=/var/cache/apt
ARG conda_dir="$app_dir/.miniconda"
ARG venv_name
ARG litellm_port=11111
ARG jupyter_port=37799
ARG nvidia_utils_driver=550

ENV TZ="$timezone"
ENV VENV_NAME="$venv_name"
ENV WORKSPACE_DIR="$workspace_dir"
ENV DEBUG="$debug"
ENV CONDA_PREFIX="$conda_dir"
ENV APP_DIR="$app_dir"
ENV PATH="${PATH}:/root/.local/bin:${CONDA_PREFIX}/bin"
ENV BIN_DIR="$bin_dir"
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR $app_dir/app
COPY . .

COPY docker/devin/app/conda.base.tmpl.yml /tmp/environment.yml
ADD --checksum=sha256:b978856ec3c826eb495b60e3fffe621f670c101150ebcbdeede4f961f22dc438 https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh /tmp/miniconda.sh

RUN --mount=type=cache,target=${apt_cache_dir},sharing=locked \
    if [ -n "${DEBUG}" ]; then set -eux; fi && \
    apt-get -q update && \
    apt-get install -qy --no-install-recommends \
      tzdata locales cpanminus curl git gnupg gnupg2 gnupg1 wget \
      nvidia-utils-${nvidia_utils_driver} && \
    if [ -z "${DEBUG}" ]; then apt-get -qy upgrade; fi && \
    rm -f /usr/lib/x86_64-linux-gnu/libcudadebugger.so.1

RUN if [ -n "${DEBUG}" ]; then set -eux; fi && \
    mkdir -p "${CONDA_PREFIX}" && \
    bash /tmp/miniconda.sh -b -u -p ${CONDA_PREFIX} && \
    sed -i "s/<CONDA_DIR>/$(echo "${CONDA_PREFIX}/envs/${VENV_NAME}" | sed -e 's/[\/&]/\\&/g')/g" /tmp/environment.yml && \
    sed -i "s/<VENV_NAME>/${VENV_NAME}/g" /tmp/environment.yml

RUN --mount=type=cache,target=$conda_pkgs_dir,sharing=locked \
    conda config --set channel_priority disabled && \
#    conda config --add channels conda && \
#    conda config --add channels conda-forge && \
    conda install -qy pip && \
    conda init -q bash && \
    conda env create -y -f /tmp/environment.yml -n "${VENV_NAME}" && \
    eval $(conda shell.bash activate "${VENV_NAME}")

RUN --mount=type=cache,target=$pip_cache_dir \
    if [ ! -z "$debug" ]; then set -eux; fi && \
    conda run -n ${VENV_NAME} pip install --upgrade pip && \
    conda install -y jupyter notebook

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

