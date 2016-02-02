#!/usr/bin/env bash

# Try getting this down a bit.

function count
{
    NUM=$(grep -ro "assert" "$1/contracts/test" | wc -l)
    echo "Assertions in $1: ${NUM}"
    TOTAL_NUM=$((TOTAL_NUM + NUM));
}

TOTAL_NUM=0

count dao-core
count dao-currency
count dao-stl
count dao-users
count dao-votes

echo "Total: ${TOTAL_NUM}"