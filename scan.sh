#!/bin/bash

echo "BOF: ${0}"

if [[ "${1}" == "clean" ]]; then
	rm -fv ~/.aws/boto/cache/*.json
fi

SAVE_DIR=$(pwd)

cd scan_for_sc_parent_stack

python -m venv venv

source venv/bin/activate

pip install boto3

TS=$(date +%Y%m%d-%H%M%S)
LOG_FILE="${SAVE_DIR}/logs/${TS}-scan_for_sc_parent_stack.log"

echo "LOG_FILE: ${LOG_FILE}"

python ./src/scan_for_sc_parent_stack.py | tee "${LOG_FILE}"

deactivate

rm -rf venv

echo "EOF: ${0}"
