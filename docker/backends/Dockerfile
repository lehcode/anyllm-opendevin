FROM litellm/openai-proxy

ARG conda_dir
ARG venv_dir
ARG venv_name
ARG debug

ENV PATH=${PATH}:/root/.local/bin:${conda_dir}/bin
ENV VENV_DIR=${venv_dir}
ENV LITELLM_PORT=${litellm_port}
ENV DEBUG=${debug}

RUN --mount=type=cache,target=/var/cache/apt \
    if [ ! -z "${debug}" ]; then set -eux; else apt update && apt -qy upgrade; fi && \
    apt install -y curl wget git && \
    mkdir -p /tmp/miniconda3 && \
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-$(uname -m).sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -u -p ${conda_dir}

SHELL ["${conda_dir}/bin/conda", "init", "bash"]
SHELL ["${conda_dir}/bin/conda", "run", "pip", "install", "openai==0.28.1"]

WORKDIR /usr/local/src
SHELL ["/bin/bash", "-c"]
RUN if [ ! -z "${debug}" ]; then set -eux; fi && \
    curl -sSL https://install.python-poetry.org | python3 && \
    git clone https://github.com/cpacker/MemGPT.git MemGPT && \
    cd ./MemGPT && \
    poetry install -E local

COPY docker/backends/entrypoint.sh /usr/local/bin/docker-entrypoint.sh
