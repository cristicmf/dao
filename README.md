# The DAO suite

### NOTE: Not ready. ETA late January or early February 2016

This is the main repository for DAO - a light-weight framework for modular systems of [Ethereum](https://ethereum.org/) contracts. It is meant to be used on Ethereum and Ethereum-like public chains that supports Ethereum contracts.

The contracts are written in the [Solidity](http://solidity.readthedocs.org/en/latest/index.html) language. The purpose of this library is to provide a secure and developer-friendly way to manage nontrivial smart-contract based applications. It is also meant to act as a template for extending, or just for educational purposes.

**Warning:** Ethereum is still experimental, and so is this code. Using this on a chain where Ether has real value, or in any form of production environment is **not** recommended.

## Getting started

The repo only has the Solidity contracts at this point, but will have scripts for automatic deployment later. Solidity imports and the compiler is being upgraded and will get some very nice new features in the coming weeks, and the scripts will make use of those.

[User Manual](./docs/Manual.md)

## Components

- [dao-core](https://github.com/smartcontractproduction/dao-core)
- dao-databases

**dao-core**

The [dao-core](https://github.com/smartcontractproduction/dao-core) library contains the core components of the system - Doug and Permission. Everything but the dao-core is optional.

**dao-databases**

NOTE: Not yet uploaded. Some cleanup left.

The dao-databases component has a number of database contracts ready to be used.
