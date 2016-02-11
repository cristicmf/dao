#!/usr/bin/env bash

# Usage: ./build_docs.sh contracts_output_dir javascript_output_dir

if [[ -z $(command -v solc) ]]; then
    echo "Cannot find NaturalDocs executable on path (http://www.naturaldocs.org/). Exiting."
    exit 1
fi

if [[ -z $(jsdoc -v solc) ]]; then
    echo "Cannot find NaturalDocs executable on path (http://www.naturaldocs.org/). Exiting."
    exit 1
fi

CONTRACTS_OUTPUT_DIR=$1
JAVASCRIPT_OUTPUT_DIR=$2

if  [ -z $1 ]; then
    echo "No output directory"
    exit 2
fi

NaturalDocs -i ./dao-core/src -i ./dao-currency/src -i ./dao-stl/src -i ./dao-users/src -i ./dao-votes/src -p ./docs/natdoc -s dao -oft -o HTML ${CONTRACTS_OUTPUT_DIR}

jsdoc --configure 'docs/jsdoc/JSDoc.json' --template node_modules/ink-docstrap/template index.js script/*.js dao-core/script/*.js dao-users/script/*.js dao-votes/script/*.js README.md --destination ${JAVASCRIPT_OUTPUT_DIR}