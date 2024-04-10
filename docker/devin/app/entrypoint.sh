#!/bin/bash --login

eval "$(conda shell.bash activate "${VENV_NAME}")"

if [ -n "${DEBUG}" ]; then
    /bin/bash < "${BIN_DIR}/env_debug"
fi

# Process named arguments
# while getopts ":-m:e:" opt; do
#   case ${opt} in
#     -m ) chat_model="$OPTARG";;
#     -e ) embeddings_model="$OPTARG";;
#     \? ) echo "Invalid option: $OPTARG" 1>&2; exit 1;;
#     : ) echo "Invalid option: $OPTARG requires an argument" 1>&2; exit 1;;
#   esac
# done
# shift $((OPTIND -1))

# python3 "/usr/local/bin/configure_devin" "$chat_model" "$embeddings_model"
#
python3 -m uvicorn opendevin.server.listen:app --reload --port "${APP_HTTP_PORT}" --host 0.0.0.0
# python3 "./opendevin/sandbox/sandbox.py" -d "${WORKSPACE_DIR}"
#
