#!/bin/bash

if [[ -z $(command -v solc) ]]; then
    echo "Cannot find solc executable on path"
    exit 1
fi

if [[ -z $1 ]]; then
    echo "No argument provided"
    exit 1
fi

MODULE=$1

# Prepare directories
BUILD_DIR="./${MODULE}/build"
SRC_DIR="./${MODULE}/src"
TEST_DIR="./${MODULE}/test"

BUILD_RELEASE_DIR=${BUILD_DIR}/release
BUILD_TEST_DIR=${BUILD_DIR}/test

# Contracts for each module
declare -a DaoCoreContracts=('DefaultDoug.sol' 'DefaultPermission.sol')
declare -a DaoCoreTest=('DefaultPermissionTest.sol' 'DefaultDougActionsTest.sol' 'DefaultDougDatabaseTest.sol' 'DefaultDougTest.sol' 'DefaultDougEnabledTest.sol' 'SimpleTest.sol')

declare -a DaoCurrencyContracts=('DefaultCurrencyDatabase.sol' 'DefaultMintedCurrency.sol' 'MintedUserCurrency.sol')
declare -a DaoCurrencyTest=('DefaultCurrencyDatabaseTest.sol' 'AbstractMintedCurrencyTest.sol' 'DefaultMintedCurrencyTest.sol' 'MintedUserCurrencyTest.sol')

declare -a DaoSTLTest=('collections/AddressSetTest.sol' 'collections/PropertySetTest.sol' 'collections/PropertyToAddressTest.sol')

declare -a DaoUsersContracts=('DefaultUserDatabase.sol' 'AdminRegUserRegistry.sol' 'SelfRegUserRegistry.sol')
declare -a DaoUsersTest=('DefaultUserDatabaseTest.sol' 'AbstractUserRegistryTest.sol' 'AdminRegUserRegistryTest.sol' 'SelfRegUserRegistryTest.sol')

declare -a DaoVotesContracts=('currency/PublicCurrency.sol' 'currency/PublicDurationBallot.sol' 'currency/PublicKeepDurationBallot.sol' 'currency/PublicMintingBallot.sol' 'currency/PublicQuorumBallot.sol')
declare -a DaoVotesTest=('BallotMapTest.sol' 'PublicBallotTest.sol' 'PublicMintingBallotTest.sol' 'PublicCurrencyBasicTest.sol' 'PublicCurrencyMintingTest.sol' 'PublicCurrencyDurationTest.sol' 'PublicCurrencyQuorumTest.sol' 'PublicCurrencyKeepDurationTest.sol')

if [ ${MODULE} != "dao-core" ] && [ ${MODULE} != "dao-users" ] && [ ${MODULE} != "dao-currency" ] && [ ${MODULE} != "dao-votes" ] && [ ${MODULE} != "dao-stl" ]; then
    echo "Param not recognized: ${MODULE}"
    exit 2
fi

# Version of dao framework
DAOVER=$(grep -Po '(?<="version": ")[^"]*' package.json)

# Write an output file in each directory.
function log() {
    SV=$(solc --version)
    printf "{\n\t\"timestamp\": $(date +%s),\n\t\"dao\": \"${DAOVER}\",\n\t\"solc\": \"${SV##*: }\",\n\t\"options\": \"$2\"\n}" > $1/build_data.txt
}

# Includes
DAO_CORE_INC="dao-core=./dao-core"
DAO_CURRENCY_INC="dao-currency=./dao-currency"
DAO_STL_INC="dao-stl=./dao-stl"
DAO_USERS_INC="dao-users=./dao-users"
DAO_VOTES_INC="dao-voters=./dao-votes"

INCLUDES=".= ${DAO_CORE_INC} ${DAO_CURRENCY_INC} ${DAO_STL_INC} ${DAO_USERS_INC} ${DAO_VOTES_INC}"

# Prepare directories
rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}
mkdir -p ${BUILD_RELEASE_DIR}
mkdir -p ${BUILD_TEST_DIR}

# Set the directories based on the chosen module
if [ ${MODULE} = "dao-core" ]; then
	CONTRACTS="${DaoCoreContracts[@]/#/${SRC_DIR}/}"
	TEST_CONTRACTS="${DaoCoreTest[@]/#/${TEST_DIR}/}"
elif [ ${MODULE} = "dao-currency" ]; then
    CONTRACTS="${DaoCurrencyContracts[@]/#/${SRC_DIR}/}"
	TEST_CONTRACTS="${DaoCurrencyTest[@]/#/${TEST_DIR}/}"
elif [ ${MODULE} = "dao-stl" ]; then
    # Only tests for standard library.
	TEST_CONTRACTS="${DaoSTLTest[@]/#/${TEST_DIR}/}"
elif [ ${MODULE} = "dao-users" ]; then
    CONTRACTS="${DaoUsersContracts[@]/#/${SRC_DIR}/}"
	TEST_CONTRACTS="${DaoUsersTest[@]/#/${TEST_DIR}/}"
elif [ ${MODULE} = "dao-votes" ]; then
    CONTRACTS="${DaoVotesContracts[@]/#/${SRC_DIR}/}"
	TEST_CONTRACTS="${DaoVotesTest[@]/#/${TEST_DIR}/}"
fi

# Compile the release contracts
if [[ ! -z ${CONTRACTS} ]]; then
    solc --bin --abi ${INCLUDES} -o ${BUILD_RELEASE_DIR} ${CONTRACTS}
    if [[ $? = 0 ]]; then
        log ${BUILD_RELEASE_DIR} "--bin --abi"
    fi
fi

# Compile the test contracts
if [[ ! -z ${TEST_CONTRACTS} ]]; then
    solc --bin --abi ${INCLUDES} -o ${BUILD_TEST_DIR} ${TEST_CONTRACTS}
    if [[ $? = 0 ]]; then
        log ${BUILD_TEST_DIR} "--bin --abi"
    fi
fi