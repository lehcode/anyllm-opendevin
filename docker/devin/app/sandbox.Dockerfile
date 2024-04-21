FROM ghcr.io/opendevin/opendevin:0.3.1

# ARG apt_cache_dir=/var/cache/apt
ARG debug=

ENV DEBUG=$debug
ENV DEBIAN_FRONTEND=noninteractive

RUN --mount=type=cache,target=${apt_cache_dir},sharing=locked \
    if [ -n "${debug}" ]; then set -eux; fi && \
    apt-get -y update && \
    if [ -z "$debug" ]; then rm -rf /var/lib/apt/lists/* ; fi

# Install NVIDIA Container Toolit
# RUN --mount=type=cache,target=${apt_cache_dir},sharing=locked \
#     if [ -n "${DEBUG}" ]; then set -eux; fi && \
#     apt-get -y install -qy --no-install-recommends \
#         ssh tzdata locales cpanminus curl git wget gnupg gnupg2 gnupg1 && \
#     curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
#     gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg && \
#     curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
#     sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
#     tee /etc/apt/sources.list.d/nvidia-container-toolkit.list && \
#     sed -i -e '/experimental/ s/^#//g' /etc/apt/sources.list.d/nvidia-container-toolkit.list && \
#     apt-get update && \
#     apt-get install -y nvidia-container-toolkit && \
#     nvidia-ctk runtime configure --runtime=docker
    
# RUN --mount=type=cache,target=${apt_cache_dir},sharing=locked \
#     apt-get -y install -qy --no-install-recommends \
#         ssh tzdata locales cpanminus curl git wget  && \
#     if [ -z "${DEBUG}" ]; then apt-get upgrade ; fi && \
#     rm -f /usr/lib/x86_64-linux-gnu/libcudadebugger.so.1 && \
#     rm -f /usr/lib/x86_64-linux-gnu/libnvidia-ml.so.1 && \
#     rm -f /usr/lib/x86_64-linux-gnu/libcuda.so.1 && \
#     if [ -z "$debug" ]; then rm -rf /var/lib/apt/lists/* ; fi

# ARG timezone=Etc/UTC
# ARG locale

# ENV LANG="$locale"
# ENV TZ="$timezone"

# ADD docker/locales /etc/locale.gen

# RUN echo "Configuring timezone and OS locales..." && \
#     if [ -n "$debug" ]; then set -eux; fi && \
#     ln -fs "/usr/share/zoneinfo/$timezone" /etc/localtime  && \
#     echo "$TZ" | tee -pa /etc/timezone  && \
#     dpkg-reconfigure -f noninteractive tzdata locales  && \
#     apt-get -q update && apt-get -qy upgrade  && \
#     rm -f /usr/lib/x86_64-linux-gnu/libcudadebugger.so.1  && \
#     rm -f /usr/lib/x86_64-linux-gnu/libnvidia-ml.so.1  && \
#     rm -f /usr/lib/x86_64-linux-gnu/libcuda.so.1  && \
#     if [ -z "$debug" ]; then rm -rf /var/lib/apt/lists/* ; fi

# COPY docker/devin/app/entrypoint.sh "/docker-entrypoint.sh"
# COPY docker/devin/app/devin_up.py "${APP_ROOT}/run/devin_up"
    
RUN if [ -n "$debug" ]; then set -eux; fi && \
    pip install debugpy status

# CMD ["uvicorn" "opendevin.server.listen:app" "--host" "0.0.0.0" "--port" "3000"]
    
# ARG devin_ws_port=3001
# ARG jupyter_port=15555
# ARG workspace_dir

# ENV WORKSPACE_DIR="$workspace_dir"

# # EXPOSE $devin_ws_port

# ARG app_root

# ENV APP_ROOT=${app_root}

# ENTRYPOINT "${APP_ROOT}/docker-entrypoint.sh"
