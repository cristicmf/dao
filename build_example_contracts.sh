#!/bin/bash

if [[ -z $(command -v solc) ]]; then
    echo "Cannot find solc executable on path"
    exit 1
fi

BASE_DIR="examples/contracts/public_currency"

# Prepare directories
BUILD_DIR="${BASE_DIR}/build"
SRC_DIR="${BASE_DIR}/src"
TEST_DIR="${BASE_DIR}/test"

BUILD_RELEASE_DIR=${BUILD_DIR}/release
BUILD_TEST_DIR=${BUILD_DIR}/test

declare -a PublicCurrencyContracts=('PublicCurrency.sol' 'PublicDurationBallot.sol' 'PublicKeepDurationBallot.sol' 'PublicMintingBallot.sol' 'PublicQuorumBallot.sol')
declare -a PublicCurrencyTest=('PublicMintingBallotTest.sol' 'PublicDurationBallotTest.sol' 'PublicQuorumBallotTest.sol' 'PublicKeepDurationBallotTest.sol' 'PublicCurrencyBasicTest.sol' 'PublicCurrencyMintingTest.sol' 'PublicCurrencyDurationTest.sol' 'PublicCurrencyQuorumTest.sol' 'PublicCurrencyKeepDurationTest.sol')

# Includes
DAO_CORE_INC="dao-core=./dao-core"
DAO_CURRENCY_INC="dao-currency=./dao-currency"
DAO_STL_INC="dao-stl=./dao-stl"
DAO_USERS_INC="dao-users=./dao-users"
DAO_VOTES_INC="dao-voters=./dao-votes"

INCLUDES=".= ${DAO_CORE_INC} ${DAO_CURRENCY_INC} ${DAO_STL_INC} ${DAO_USERS_INC} ${DAO_VOTES_INC} public-currency=${BASE_DIR}"

# Prepare directories
rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}
mkdir -p ${BUILD_RELEASE_DIR}
mkdir -p ${BUILD_TEST_DIR}

CONTRACTS="${PublicCurrencyContracts[@]/#/${SRC_DIR}/}"
TEST_CONTRACTS="${PublicCurrencyTest[@]/#/${TEST_DIR}/}"

solc --bin --abi ${INCLUDES} -o ${BUILD_RELEASE_DIR} ${CONTRACTS}

solc --bin --abi ${INCLUDES} -o ${BUILD_TEST_DIR} ${TEST_CONTRACTS}
