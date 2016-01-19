#!/bin/bash

# Temporary script. Will be simplified a _lot_ when the new solc imports are added.

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

STD_LIB_SRC="./dao-stl/src"
DAO_CORE_SRC="./dao-core/contracts/src"


declare -a DaoCoreContracts=('DefaultDoug.sol' 'DefaultPermission.sol' 'Doug.sol' 'Permission.sol' 'Database.sol')
declare -a DaoCoreExternal=('errors/Errors.sol')
declare -a DaoCoreTest=('DefaultPermissionTest.sol' 'DougActionsTest.sol' 'DougBase.sol' 'DougDatabaseTest.sol' 'DougEnabledTest.sol' 'DougTest.sol')
declare -a DaoCoreTestExternal=('assertions/Asserter.sol' 'assertions/DaoAsserter.sol')

declare -a DaoUsersContracts=('UserDatabase.sol' 'DefaultUserDatabase.sol' 'AdminUserRegistry.sol' 'UserRegistryAdminReg.sol' 'UserRegistrySelfReg.sol')
declare -a DaoUsersExternal=('errors/Errors.sol')
declare -a DaoUsersTest=('MockDatabaseDoug.sol' 'UserDatabaseTest.sol')
declare -a DaoUsersTestExternal=('assertions/Asserter.sol' 'assertions/DaoAsserter.sol')

if [ ${MODULE} != "dao-core" ] && [ ${MODULE} != "dao-users" ]; then
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
	EXT_CONTRACTS="${DaoCoreExternal[@]/#/${STD_LIB_SRC}/}"
	TEST_CONTRACTS="${DaoCoreTest[@]/#/${TEST_DIR}/}"
	TEST_EXT_CONTRACTS="${DaoCoreTestExternal[@]/#/${STD_LIB_SRC}/}"
elif [ ${MODULE} = "dao-users" ]; then
    CONTRACTS="${DaoUsersContracts[@]/#/${SRC_DIR}/}"
	EXT_CONTRACTS="${DaoUsersExternal[@]/#/${STD_LIB_SRC}/}"
	EXT_CONTRACTS+=" ${DaoCoreContracts[@]/#/${DAO_CORE_SRC}/}"
	TEST_CONTRACTS="${DaoUsersTest[@]/#/${TEST_DIR}/}"
	TEST_EXT_CONTRACTS="${DaoUsersTestExternal[@]/#/${STD_LIB_SRC}/}"
fi

solc --bin --abi -o ${BUILD_RELEASE_DIR} ${CONTRACTS} ${EXT_CONTRACTS}
solc --bin --abi -o ${BUILD_TEST_DIR} ${CONTRACTS} ${EXT_CONTRACTS} ${TEST_CONTRACTS} ${TEST_EXT_CONTRACTS}
solc --devdoc -o ${BUILD_DOCS_DIR} ${CONTRACTS} ${EXT_CONTRACTS}