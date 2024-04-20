FROM ghcr.io/opendevin/opendevin:0.3.1

# ARG apt_cache_dir=/var/cache/apt
ARG debug=${DEBUG}

ENV DEBIAN_FRONTEND=noninteractive

# RUN --mount=type=cache,target=${apt_cache_dir},sharing=locked \
#     echo "Updating packages..." && \
#     if [ -n "${DEBUG}" ]; then set -eux; fi && \
#     apt-get -y update  && \
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
