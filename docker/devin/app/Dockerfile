ARG cuda_version=12.4.0
ARG ubuntu_tag=ubuntu20.04
ARG tag="${cuda_version}-devel-${ubuntu_tag}"
FROM nvidia/cuda:${tag} as build

LABEL org.opencontainers.image.description="Devin with Nvidia CUDA v${cuda_version} and Miniconda3"
LABEL org.opencontainers.image.author="lehcode <53556648+lehcode@users.noreply.github.com>"

ARG cuda_version
ARG ubuntu_version
ARG apt_cache_dir=/var/cache/apt
ARG nvidia_utils_driver=550
ARG debug

ENV DEBUG="$debug"
ENV DEBIAN_FRONTEND=noninteractive

ADD --checksum=sha256:b978856ec3c826eb495b60e3fffe621f670c101150ebcbdeede4f961f22dc438 https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh /tmp/miniconda.sh

RUN --mount=type=cache,target=${apt_cache_dir},sharing=locked \
    if [ -n "${DEBUG}" ]; then set -eux; fi && \
    apt-get -q update && \
    apt-get install -qy --no-install-recommends \
      tzdata locales cpanminus curl git gnupg gnupg2 gnupg1 wget \
      nvidia-utils-${nvidia_utils_driver} && \
    if [ -z "${DEBUG}" ]; then apt-get -qy upgrade; fi

ARG timezone
ARG locale
ENV LANG="$locale"
ENV TZ="$timezone"
COPY docker/locales /etc/locale.gen

RUN if [ -n "${DEBUG}" ]; then set -eux; fi && \
    ln -fs "/usr/share/zoneinfo/$timezone" /etc/localtime && \
    echo "$TZ" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata locales && \
    apt-get -q update && \
    apt-get -qy upgrade && \
    rm -f /usr/lib/x86_64-linux-gnu/libcudadebugger.so.1 && \
    rm -f /usr/lib/x86_64-linux-gnu/libnvidia-ml.so.1 && \
    rm -f /usr/lib/x86_64-linux-gnu/libcuda.so.1 && \
    if [ -z "${DEBUG}" ]; then rm -rf /var/lib/apt/lists/*; fi

COPY docker/devin/app/conda.base.tmpl.yml /tmp/environment.yml

ARG conda_dir
ENV CONDA_PREFIX=$conda_dir

ARG venv_name

ENV PATH="${PATH}:/root/.local/bin:${CONDA_PREFIX}/bin"
ENV VENV_NAME="$venv_name"

#RUN echo $PATH && env && exit 1

RUN if [ -n "${DEBUG}" ]; then set -eux; fi && \
    mkdir -p "${CONDA_PREFIX}" && \
    bash /tmp/miniconda.sh -b -u -p ${CONDA_PREFIX} && \
    sed -i "s/<CONDA_DIR>/$(echo "${CONDA_PREFIX}/envs/${VENV_NAME}" | sed -e 's/[\/&]/\\&/g')/g" /tmp/environment.yml && \
    sed -i "s/<VENV_NAME>/${VENV_NAME}/g" /tmp/environment.yml

ARG conda_pkgs_dir=$CONDA_PREFIX/pkgs

RUN --mount=type=cache,target=${conda_pkgs_dir},sharing=locked \
    if [ -n "${DEBUG}" ]; then set -eux; fi && \
    conda config --set channel_priority disabled && \
    conda install -qy pip && \
    conda init -q bash && \
    conda env create -y -f /tmp/environment.yml -n "${VENV_NAME}"

RUN --mount=type=cache,target=${conda_pkgs_dir},sharing=locked \
    if [ -n "${DEBUG}" ]; then set -eux; fi && \
    conda install -y -n "${VENV_NAME}" pip && \
    conda run -n ${VENV_NAME} pip install --upgrade pip && \
    conda install -y -n "${VENV_NAME}" pytorch::pytorch==2.2.2

# Make RUN commands use the new environment
SHELL ["conda", "run", "-n", "od_env", "/bin/bash", "-c"]

WORKDIR /usr/local/src/chromadb

ARG pip_cache_dir=/root/.cache/pip

RUN --mount=type=cache,target=${pip_cache_dir},sharing=locked \
    if [ -n "${DEBUG}" ]; then set -eux; fi && \
    eval conda shell.bash activate "${VENV_NAME}" && \
    git clone https://github.com/chroma-core/chroma.git . && \
    pip install -q -r requirements.txt && \
    pip install .

ARG app_dir
ENV APP_DIR="$app_dir"

WORKDIR ${APP_DIR}
COPY requirements.txt .

RUN --mount=type=cache,target=${pip_cache_dir},sharing=locked \
    if [ -n "${DEBUG}" ]; then set -eux; fi && \
    eval conda shell.bash activate "${VENV_NAME}" && \
    pip install -r requirements.txt && \
    pip install uvicorn jupyter notebook playwright

RUN if [ ! -z "${DEBUG}" ]; then set -eux; fi && \
    eval conda shell.bash activate "${VENV_NAME}" && \
    pip freeze --local --all -r "$APP_DIR/requirements.txt"

ENV BIN_DIR=$bin_dir

ARG litellm_port=11111
ARG jupyter_port=37799

COPY . ${APP_DIR}
COPY docker/devin/app/entrypoint.sh /docker-entrypoint.sh
COPY docker/devin/app/configure.py "${APP_DIR}/configure_devin"
COPY docker/env_debug.sh /usr/local/bin/env_debug
