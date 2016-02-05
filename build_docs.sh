#!/usr/bin/env bash

if [[ -z $(command -v solc) ]]; then
    echo "Cannot find NaturalDocs executable on path (http://www.naturaldocs.org/). Exiting."
    exit 1
fi

if [[ -z $1 ]]; then
    echo "No argument provided"
    exit 1
fi

MODULE=$1

if  [ ${MODULE} != "dao-core" ] && [ ${MODULE} != "dao-users" ] && [ ${MODULE} != "dao-currency" ] && [ ${MODULE} != "dao-votes" ] && [ ${MODULE} != "dao-stl" ]; then
    echo "Param not recognized: ${MODULE}"
    exit 2
fi

NaturalDocs -i ./${MODULE}/src -p ./docs/natdoc/${MODULE} -s dao -oft -o HTML ./${MODULE}/doc