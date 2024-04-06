#!/usr/bin/env bash

[[ ! -z "${DEBUG}" ]]; set -eux

[[ ! -z "${DEBUG}" ]]; litellm --help
litellm --file /etc/litellm_config.yaml --port "${LITELLM_PORT}"
