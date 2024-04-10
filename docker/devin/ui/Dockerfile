ARG node_version
ARG npm_version
FROM node:${node_version}-alpine as build-front

COPY docker/openssl.cnf /etc/ssl/openssl.cnf

RUN if [ -n "${DEBUG}" ]; then set -eux; fi && \
    apk update && \
    if [ -z "${DEBUG}" ]; then apk upgrade; fi && \
    apk add git openssl

RUN if [ -n "${DEBUG}" ]; then set -eux; fi && \
    mkdir -p /root/devin/ssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout /root/devin/ssl/privkey.pem \
      -out /root/devin/ssl/fullchain.pem \
      -config /etc/ssl/openssl.cnf

WORKDIR /src/ui/frontend

COPY frontend/ /src/ui/frontend
COPY .git /src/ui/.git

RUN --mount=type=cache,target=/root/.local/share/pnpm/store \
    if [ -n "${DEBUG}" ]; then set -eux; fi && \
    if [ -z ./.npmrc ]; then touch ./.npmrc; fi && \
    if [ -n "${DEBUG}" ]; then echo "loglevel=silent" | tee -a ./.npmrc; fi && \
    npm install -g npm@${npm_version} pnpm && \
    SHELL=bash pnpm setup

RUN --mount=type=cache,target=/root/.local/share/pnpm/store \
    if [ -n "${DEBUG}" ]; then set -eux; fi && \
    source /root/.bashrc && \
    pnpm install && \
    pnpm run build

FROM node:${node_version}-slim as service

ARG ui_dir
ENV UI_DIR=$ui_dir

COPY --from=build-front /src/ui/frontend/dist/ ${UI_DIR}/
COPY frontend/package.json ${UI_DIR}/
COPY --from=build-front /src/ui/frontend/.npmrc ${UI_DIR}/
COPY --from=build-front /root/.bashrc /root/

ENV PATH="${PATH}:${UI_DIR}/node_modules/.bin"

WORKDIR ${UI_DIR}

RUN --mount=type=cache,target=/root/.local/share/pnpm/store \
    if [ -n "${DEBUG}" ]; then set -eux; fi && \
    npm install -g npm@${npm_version} pnpm && \
    SHELL=bash pnpm setup && \
    . /root/.bashrc && \
    pnpm install

CMD ["pnpm", "run", "preview"]
