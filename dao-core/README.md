# dao-core

dao-core is the centerpiece of the DAO framework. It has the contract registry and 

## Installation and Usage

[User manual](https://github.com/smartcontractproduction/dao/blob/master/docs/Manual.md)

node.js is needed to run the helper scripts.

#### Deployment

Deployment to an Ethereum chain can be done using `dao-core/script/ethereum/deploy.js`.
 
There will be more deployment options later.

#### Building/rebuilding of contracts

NOTE: Requires `solc`.

Shell script: `$ ./build_contracts.sh dao-core`

Gulp: `$ gulp build:core`

#### Testing

From the dao project root:

Gulp: `$ gulp test:core` 

Command-line tool: `$ solunit -d ./dao-core/contracts/build/test`

### Contracts

#### Doug

Doug is the top level contract. It has a permissions contract, registries for actions and database contracts, and a number of basic options.

In the default implementation, the creator of Doug supplies the address to an already deployed `Permission` contract in the constructor. Doug will then use that to check if a caller is allowed to add, modify, or remove any of its contracts, or change the properties. By default it will also disallow everything if the permissions contract was not set (i.e. the address is nil).

The `Doug` contract itself is an interface, and `DefaultDoug` is the default implementation. 

#### DougEnabled

`DougEnabled` is an interface that contracts must implement in order to be added to Doug.
 
Note that this interface does not guarantee that a contract is safe to add, it just makes it easier for developers to create contracts that works with the system.

#### Permission

The permission contract is used to control access to Doug functionality, such as adding and removing contracts, and changing its options. It has an interface, `Permission` and a default implementation, `DefaultPermission`. Doug works with the interface, and the contract can be replaced by the user with (Doug) root permission, so it is possible to write a custom permission contract and use that instead.

#### Database

`Database` is a contract that extends `DefaultDougEnabled` and adds an internal method for checking if the calling contract is registered as a Doug actions contract. It is not required, but is slightly more convenient then writing that check alone. It can be extended by contracts that are registered as databases in the system.