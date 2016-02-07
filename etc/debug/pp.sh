#!/usr/bin/env bash

if [[ -z $(command -v solc) ]]; then
    echo "Cannot find solc executable on path"
    exit 1
fi

if [[ -z $(command -v gpp) ]]; then
    echo "Cannot find gpp executable on path"
    exit 1
fi

if [[ $1 = "DEBUG" ]]; then
    gpp TestPreproc.solp -DDEBUG -o TestPreproc.sol
else
    gpp TestPreproc.solp -o TestPreproc.sol
fi

solc --bin --abi -o . TestPreproc.sol