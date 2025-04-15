#!/bin/bash

echo "BOF: ${0}"

if [[ "${1}" == "clean" ]]; then
	rm -fv ~/.aws/boto/cache/*.json
fi

cd scan_for_sc_parent_stack

python -m venv venv

source venv/bin/activate

pip install boto3

python ./src/scan_for_sc_parent_stack.py

deactivate

rm -rf venv

echo "EOF: ${0}"
