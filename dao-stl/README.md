# dao-stl

Standard contracts used throughout the entire framework.

## Installation and Usage

#### Deployment

The `AddressSetDb` contracts in tests can be deployed onto an Ethereum chain and tested using `dao-stl/script/ethereum/deploy_address_set.js`.

It is possible to deploy Doug and run some calls as well, using `dao-core/script/ethereum/deploy_and_test.js`
 
There will be more options later.

#### Building/rebuilding of contracts

NOTE: Requires `solc`. Will only build tests (nothing else to build).

Shell script: `$ ./build_contracts.sh dao-stl`

Gulp: `$ gulp build:stl`

#### Testing

Gulp: `$ gulp test:stl`

Command-line tool: `$ solunit -d ./dao-stl/build/test`

#### Docs

Shell script: `$ ./build_docs.sh dao-stl`

Gulp: `$ gulp htmldoc:stl`

## Packages

* [Assertions](#assertions)
* [Collections](#collections)
* [Errors](#errors)

### Assertions

Contracts needed for making assertions (sol-unit compatible).

### Collections

A few standard collections. The key and value types are mostly `address` and `bytes32`. `bytes32` is a fixed size byte array, which can serve as a string, number or other things, and is therefore referred to as `property` in this library.

### Errors

Contracts used to handle errors.