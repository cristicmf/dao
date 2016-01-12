# The DAO suite

### NOTE: Not ready. ETA late January or early February 2016

This is the main repository for DAO - a light-weight framework for modular systems of [Ethereum](https://ethereum.org/) contracts. It is meant to be used on Ethereum and Ethereum-like public chains that supports Ethereum contracts.

The contracts are written in the [Solidity](http://solidity.readthedocs.org/en/latest/index.html) language. The purpose of this library is to provide a secure and developer-friendly way to manage nontrivial smart-contract based applications. It is also meant to act as a template for extending, or just for educational purposes.

**Warning:** Ethereum is still experimental, and so is this code. Using this on a chain where Ether has real value, or in any form of production environment is **not** recommended.

## Getting started

The repo only has the Solidity contracts at this point, but will have scripts for automatic deployment later. Solidity imports and the compiler is being upgraded and will get some very nice new features in the coming weeks, and the scripts will make use of those.

The best way to get started is the [Getting Started](./docs/Manual.md#getting-started) section of the
[User Manual](./docs/Manual.md).

## Dependencies and tools

This is only tested on 64 bit Ubuntu 14.04+

**Test contracts only**

The [Solidity online compiler](https://chriseth.github.io/browser-solidity/) is all you need.

**Deployment and other scripts**

Deployment and other script is done using the official [Ethereum javascript library](https://github.com/ethereum/web3.js) web3.js.

[node.js](https://nodejs.org/en/) and command-line [Gulp](http://gulpjs.com/) is optional.

**Compiling contracts**

You need [solc](https://github.com/ethereum/solidity) on your path (always latest dev).

You do not need this for examples and such.

**Formal proofs**

You need [why3](http://why3.lri.fr/) (latest release).

This is not required for normal usage.

## Components

- [dao-core](https://github.com/smartcontractproduction/dao-core)

#### Utilities

- [dao-collections](https://github.com/smartcontractproduction/dao-collections)

**dao-core**

The [dao-core](https://github.com/smartcontractproduction/dao-core) library contains the core components of the system - Doug and Permission. Everything but the dao-core is optional.

**dao-collections**

A number of collections such as maps, multi-maps and sets.

## DAO framework?

Yes, this is a framework for DAOs. Decenralized Autonomous Organizations. 

One could argue that it isn't an actual DAO framework, because if there are administrator accounts then the organization is not really autonomous. This is correct, but it is *possible* to create autonomous systems, or those that are "somewhat autonomous" (through the use of voting and other mechanisms). 

It really works like Ethereum contracts. Ethereum contracts are often called smart-contracts even though they don't have to be smart, and they don't have to be [legal] contracts; the Ethereum protocol can't be used to check if that is indeed what they are. Similarly, the DAO framework lets you create DAOs, but they don't have to be distributed, autonomous, or organizations. You can create a fully managed single user system and deploy it on an offline block-chain node, nothing in this framework will prevent you from doing that, but if you want to create a DAO you can do that too.