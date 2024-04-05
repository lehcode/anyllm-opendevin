FROM nvidia/cuda:12.3.2-devel-ubuntu22.04 as build-sandbox

LABEL org.opencontainers.image.description="Devin server with CUDA support"

ARG venv_name
ARG app_dir
ARG venv_dir
ARG debug
ARG conda_dir
ARG workspace_dir
ARG node_version

ENV VENV_DIR=${venv_dir}
ENV VENV_NAME=${venv_name}
ENV WORKSPACE_DIR=${workspace_dir}
ENV DEBUG=${debug}

RUN --mount=type=cache,target=/var/cache/apt \
    if [ ! -z "${debug}" ]; then set -eux; fi && \
    apt update && apt -qy upgrade

WORKDIR ${app_dir}

COPY requirements.txt .

ENV PATH=${PATH}:${conda_dir}/bin
ENV APP_DIR=${app_dir}

RUN --mount=type=cache,target=/var/cache/apt \
    if [ ! -z "${debug}" ]; then set -eux; else apt update && apt -qy upgrade; fi && \
    apt install -qy wget ca-certificates build-essential && \
    mkdir -p /tmp/miniconda3 && \
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-$(uname -i).sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -u -p ${conda_dir} && \
    ${conda_dir}/bin/conda init bash && \
    ${conda_dir}/bin/python3 -m pip install -r requirements.txt

COPY docker/devin/app/entrypoint.sh /opt/nvidia/nvidia_entrypoint.sh
