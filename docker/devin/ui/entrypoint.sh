#!/bin/bash --login

if [ -n "${DEBUG}" ]; then set -eux; fi

PATH="${PATH}:$yarn_global_root/node_modules/npm/bin:$yarn_global_root/bin"

pwd

echo ${PATH}

# yarn install

ls -al . | grep node_modules


if [ -n "${DEBUG}" ]; then
    vite --config vite.config.ext.js --debug --host 0.0.0.0 --port "${UI_HTTP_PORT:?}" --clearScreen false
else
    vite --config vite.config.ext.js --host 0.0.0.0 --port "${UI_HTTP_PORT:?}" --clearScreen false
fi
