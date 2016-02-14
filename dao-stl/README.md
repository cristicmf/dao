# dao-stl

Standard contracts used throughout the entire framework.

## Installation and Usage

#### Deployment

The `AddressSetDb` contracts in tests can be deployed onto an Ethereum chain and tested using `dao-stl/script/bin/deploy_address_set.js`.

#### Building/rebuilding of contracts

NOTE: Requires `solc`. Will only build tests (nothing else to build).

Shell script: `$ ./build_contracts.sh dao-stl`

Gulp: `$ gulp build:stl`

### Usage

[User manual](https://github.com/smartcontractproduction/dao/blob/master/docs/Manual.md)

## Packages

* [Assertions](#assertions)
* [Collections](#collections)
* [Contracts](#contracts)
* [Errors](#errors)

### Assertions

Contracts needed for making assertions (sol-unit compatible).

### Collections

A few standard collections. The key and value types are mostly `address` and `bytes32`. `bytes32` is a fixed size byte array, which can serve as a string, number or other things, and is therefore referred to as `property` in this library.

### Contracts

A few basic contracts like `Destructible`.

### Errors

Contracts used to handle errors.