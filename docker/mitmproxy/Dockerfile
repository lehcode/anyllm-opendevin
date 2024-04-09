FROM python:3.11-bullseye as wheelbuilder

LABEL org.opencontainers.image.description="mitmproxy (mitmproxy.org) version specific build"

ARG version
ARG proxy_wheel

ADD https://downloads.mitmproxy.org/${version}/${proxy_wheel} /wheels/

SHELL ["/bin/sh", "-c"]

RUN pip install wheel && \
    pip wheel --wheel-dir /wheels /wheels/${proxy_wheel}

FROM python:3.11-slim-bullseye

ARG mitmproxy_dir
ARG uid
ARG gid

ENV MITMPROXY_DIR=${mitmproxy_dir}

SHELL ["/bin/sh", "-c"]

RUN --mount=type=cache,target=/var/cache/apt \
    groupadd -g ${gid} mitmproxy && \
    useradd -m -u ${uid} -g ${gid} mitmproxy && \
    apt update && apt -qy upgrade && \
    apt install -y --no-install-recommends gosu nano && \
    rm -rf /var/lib/apt/lists/*

COPY ./docker/mitmproxy/entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod 775 /usr/local/bin/docker-entrypoint.sh

COPY --from=wheelbuilder /wheels /wheels

RUN pip install --no-index --find-links=/wheels mitmproxy
RUN rm -rf /wheels

VOLUME ${mitmproxy_dir}

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["mitmproxy"]
