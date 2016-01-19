#!/usr/bin/env bash

if [[ -z $(command -v solc) ]]; then
    echo "Cannot find solc executable on path. Exiting."
    exit 1
fi

if [[ -z $(command -v why3) ]]; then
    echo "Cannot find why3 executable on path. Exiting."
    exit 1
fi

solc --formal -o /tmp/binarysearch/ BinarySearch.sol
why3 prove -P z3 -a split_goal_full /tmp/binarysearch/solidity.mlw