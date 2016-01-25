#!/bin/bash

if [[ -z $(command -v solc) ]]; then
    echo "Cannot find solc executable on path"
    exit 1
fi

MODULE=$1

BUILD_DIR="./${MODULE}/contracts/build"
SRC_DIR="./${MODULE}/contracts/src"
TEST_DIR="./${MODULE}/contracts/test"

BUILD_RELEASE_DIR=${BUILD_DIR}/release
BUILD_TEST_DIR=${BUILD_DIR}/test
BUILD_DOCS_DIR=${BUILD_DIR}/docs


declare -a DaoCoreContracts=('DefaultDoug.sol' 'DefaultPermission.sol' 'Database.sol')
declare -a DaoCoreTest=('DefaultPermissionTest.sol' 'DefaultDougActionsTest.sol' 'DefaultDougDatabaseTest.sol' 'DefaultDougTest.sol' 'DefaultDougEnabledTest.sol')

declare -a DaoCurrencyContracts=('DefaultCurrencyDatabase.sol' 'DefaultMintedCurrency.sol' 'MintedUserCurrency.sol')
declare -a DaoCurrencyTest=('DefaultCurrencyDatabaseTest.sol' 'DefaultMintedCurrencyTest.sol' 'MintedUserCurrencyTest.sol')

declare -a DaoUsersContracts=('DefaultUserDatabase.sol' 'UserRegistryAdminReg.sol' 'UserRegistrySelfReg.sol')
declare -a DaoUsersTest=('DefaultUserDatabaseTest.sol')

declare -a DaoVotesContracts=('MintBallot.sol' 'MintBallotManager.sol')
declare -a DaoVotesTest=('PublicBallotTest.sol')

if [ ${MODULE} != "dao-core" ] && [ ${MODULE} != "dao-users" ] && [ ${MODULE} != "dao-currency" ] && [ ${MODULE} != "dao-votes" ]; then
    echo "Param not recognized: ${MODULE}"
    exit 2
fi

rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}
mkdir -p ${BUILD_RELEASE_DIR}
mkdir -p ${BUILD_TEST_DIR}
mkdir -p ${BUILD_DOCS_DIR}

if [ ${MODULE} = "dao-core" ]; then
	CONTRACTS="${DaoCoreContracts[@]/#/${SRC_DIR}/}"
	TEST_CONTRACTS="${DaoCoreTest[@]/#/${TEST_DIR}/}"
elif [ ${MODULE} = "dao-currency" ]; then
    CONTRACTS="${DaoCurrencyContracts[@]/#/${SRC_DIR}/}"
	TEST_CONTRACTS="${DaoCurrencyTest[@]/#/${TEST_DIR}/}"
elif [ ${MODULE} = "dao-users" ]; then
    CONTRACTS="${DaoUsersContracts[@]/#/${SRC_DIR}/}"
	TEST_CONTRACTS="${DaoUsersTest[@]/#/${TEST_DIR}/}"
elif [ ${MODULE} = "dao-votes" ]; then
    CONTRACTS="${DaoVotesContracts[@]/#/${SRC_DIR}/}"
	TEST_CONTRACTS="${DaoVotesTest[@]/#/${TEST_DIR}/}"
fi

solc --bin --abi -o ${BUILD_RELEASE_DIR} ${CONTRACTS}
solc --bin --abi -o ${BUILD_TEST_DIR} ${TEST_CONTRACTS}
solc --devdoc -o ${BUILD_DOCS_DIR} ${CONTRACTS}