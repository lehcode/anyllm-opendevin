ARG node_version
FROM node:${node_version}-alpine as build-front

ARG ui_dir
ARG debug
ARG node_env

ENV NODE_ENV=${node_env}

WORKDIR ${ui_dir}

COPY frontend/dist .
COPY frontend/src .
COPY frontend/package.json .
COPY frontend/tsconfig.json .
COPY frontend/*.config.js .
COPY frontend/vite*.ts .

RUN --mount=type=cache,target=${HOME}/.npm \
    if [ ! -z "${debug}" ]; then set -eux; else apk update && apk upgrade; fi && \
    apk add git && \
    npm install -g npm pnpm && \
    pnpm install && \
    pnpm run build

CMD ["pnpm", "run", "preview"]
