ARG node_version
FROM node:${node_version}-alpine as build-front

ARG ui_dir
ARG debug
ARG node_env

ENV NODE_ENV=${node_env}

WORKDIR /etc/nginx

RUN if [ ! -z "$debug" ]; set -eux && \
    apk update && \
    if [ ! -z "$debug" ]; apk upgrade && \
    apk add git && \
    npm install -g npm pnpm && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout privkey.pem -out fullchain.pem

WORKDIR $ui_dir

#COPY frontend/dist .
COPY frontend/src .
COPY frontend/package.json .
COPY frontend/tsconfig.json .
COPY frontend/*.config.js .
COPY frontend/vite*.ts .

RUN pnpm install && \
    pnpm run build

FROM nginx:latest as prod

WORKDIR $ui_dir

COPY --from=build-front $ui_dir/frontend/dist /var/www/app
COPY --from=build-front /etc/nginx/ssl /etc/nginx/ssl

CMD ["pnpm", "run", "preview"]
