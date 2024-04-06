ARG cuda_version
ARG cuda_image_os
FROM nvidia/cuda:${cuda_version}-devel-${cuda_image_os} as build

LABEL org.opencontainers.image.description="Devin Image with Nvidia CUDA ${cuda_version} support"

ARG venv_name=od_env
ARG app_dir
ARG debug
ARG workspace_dir
ARG conda_dir=/root/miniconda3

ENV VENV_NAME=$venv_name
ENV VENV_DIR=$conda_dir/envs/$venv_name
ENV WORKSPACE_DIR=$workspace_dir
ENV DEBUG=$debug
ENV PATH=${PATH}:$conda_dir/bin
ENV APP_DIR=$app_dir
ENV CONDA_DIR=$conda_dir

WORKDIR ${APP_DIR}

COPY docker/devin/app/environment.base.tmpl.yml environment.yml
ADD https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh /tmp/miniconda.sh

RUN --mount=type=cache,target=/var/cache/apt \
    if [ ! -z "$debug" ]; then set -eux; fi && \
    apt -q update && \
    if [ -z "$debug" ]; then apt -qy upgrade; fi && \
    apt install -qy --no-install-recommends wget ca-certificates curl git && \
    if [ ! -d "$conda_dir/envs/$venv_name" ]; then bash /tmp/miniconda.sh -b -u -p ${CONDA_DIR}; fi && \
    sed -i "s/<CONDA_DIR>/$(echo "$conda_dir" | sed -e 's/[\/&]/\\&/g')/g" environment.yml && \
    sed -i "s/<VENV_NAME>/$venv_name/g" environment.yml

RUN --mount=type=cache,target=/root/.cache/pip \
    if [ ! -z "$debug" ]; then set -eux; fi && \
    pip install -q --upgrade pip

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
SHELL ["conda", "run", "-n", "od_env", "--"]

COPY docker/devin/app/entrypoint.sh /opt/nvidia/nvidia_entrypoint.sh

