# dao-core

dao-core is the centerpiece of the DAO framework. It has the contract registry and 

## Installation and Usage

[User manual](https://github.com/smartcontractproduction/dao/blob/master/docs/Manual.md)

node.js is needed to run the helper scripts.

#### Deployment

Deployment to an Ethereum chain can be done using `dao-core/script/ethereum/deploy.js`.
 
There will be more deployment options later.

#### Building/rebuilding of contracts

NOTE: Requires `solc` and `GNU make`.

Either run `make` from `daoc-re/contracts` or `gulp build-contracts`.

## Testing

Contract tests are done using [sol-unit](https://github.com/androlo/sol-unit).

Gulp: `gulp test-contracts` (the `contracts/build/test` folder must be intact)

Command-line tool: `npm install -g sol-unit`, `cd` into `dao-core/contracts/build/test` and run `solunit`.

