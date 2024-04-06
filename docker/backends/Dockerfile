ARG cuda_version
ARG cuda_image_os
FROM nvidia/cuda:$cuda_version-devel-$cuda_image_os as build

LABEL org.opencontainers.image.description="Devin backends image with NVidia CUDA v$cuda_version"
LABEL org.opencontainers.image.cuda_version=$cuda_version

ARG conda_dir=/root/miniconda3
ARG debug
ARG venv_name

ENV PATH=$PATH:/root/.local/bin:$conda_dir/bin
ENV LITELLM_PORT=$litellm_port
ENV DEBUG=$debug
ENV VENV_NAME=$venv_name
ENV CONDA_DIR=$conda_dir

WORKDIR /root

COPY docker/backends/environment.base.tmpl.yml environment.yml
ADD https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh /tmp/miniconda.sh

RUN --mount=type=cache,target=/var/cache/apt \
    if [ ! -z "$debug" ]; then set -eux; fi && \
    apt -q update && \
    if [ -z "$debug" ]; then apt -qy upgrade; fi && \
    apt install -qy --no-install-recommends git curl ca-certificates && \
    if [ ! -d "$conda_dir/envs/$venv_name" ]; then bash /tmp/miniconda.sh -b -u -p ${CONDA_DIR}; fi && \
    sed -i "s/<CONDA_DIR>/$(echo "$conda_dir" | sed -e 's/[\/&]/\\&/g')/g" environment.yml && \
    sed -i "s/<VENV_NAME>/$venv_name/g" environment.yml

RUN --mount=type=cache,target=/root/.cache/pip \
    if [ ! -z "$debug" ]; then set -eux; fi && \
    pip install --upgrade pip

RUN --mount=type=cache,target=/root/anaconda/pkgs \
    conda config --set channel_priority disabled && \
    conda config --prepend channels conda && \
    conda config --prepend channels conda-forge && \
    conda init -q bash && \
    conda env create -y -f environment.yml -n "$venv_name"

RUN --mount=type=cache,target=/root/.cache/pip \
    conda install -y -n "$venv_name" pip

ARG memgpt_config_path
ENV MEMGPT_CONFIG_PATH=$memgpt_config_path

WORKDIR /usr/local/src/memgpt

RUN --mount=type=cache,target=/root/.cache/pip \
    if [ ! -z "$debug" ]; then set -eux; fi && \
    git clone https://github.com/cpacker/MemGPT.git . && \
    conda run -n "$venv_name" pip install -e . && \
    conda run -n "$venv_name" pip install -e '.[local]'

SHELL ["conda", "run", "-n", "od_env", "--"]

COPY docker/backends/entrypoint.sh /opt/nvidia/nvidia_entrypoint.sh
