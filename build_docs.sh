#!/usr/bin/env bash

if [[ -z $(command -v solc) ]]; then
    echo "Cannot find NaturalDocs executable on path (http://www.naturaldocs.org/). Exiting."
    exit 1
fi

OUTPUT_DIR=$1

if  [ -z $1 ]; then
    echo "No output directory"
    exit 2
fi

NaturalDocs -i ./dao-core/src -i ./dao-currency/src -i ./dao-stl/src -i ./dao-users/src -i ./dao-votes/src -p ./docs/natdoc -s dao -oft -o HTML $1