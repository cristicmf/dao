# The DAO suite

## NOTICES

- This library is not ready. ETA late January or early February 2016. There are some improvements to `solc` imports [just around the corner](https://www.pivotaltracker.com/story/show/102848776). Will change the imports once that is done, and then release.

- Ethereum is still experimental, and so is this code. Using this on a chain where Ether has real value, or in any form of production environment is **not** recommended.

- The code in `dao-core` and `dao-users` is stable, but again - imports will change. 

## Information

This is the main repository for DAO - a light-weight framework for modular systems of [Ethereum](https://ethereum.org/) contracts. It is meant to be used on Ethereum and Ethereum-like public chains that supports Ethereum contracts.

The contracts are written in the [Solidity](http://solidity.readthedocs.org/en/latest/index.html) language. The purpose of this library is to provide a secure and developer-friendly way to manage nontrivial smart-contract based applications. It is also meant to act as a template for extending, or just for educational purposes.

This is a contracts-only library. There is some javascript to help deploying and testing and such, but all of that is optional.

## Getting started

The best way to get started is reading the [User Manual](./docs/Manual.md).

## Dependencies and tools

This is only tested on 64 bit Ubuntu 14.04+ 

[node.js](https://nodejs.org/en/) is a requirement for most of the scripts. The scripts are based on the official javascript APIs, such as the [Ethereum web3.js library](https://github.com/ethereum/web3.js), and are used for deployment and testing etc. 

Command-line [Gulp](http://gulpjs.com/) is optional, but has tasks for building and deploying.

You need [solc](https://github.com/ethereum/solidity) on your path to compile locally (always latest dev). You also need `GNU make`. NOTE: These are placeholders until new imports are done, and the Javascript Solidity compiler is available.

**Formal proofs**

You need [why3](http://why3.lri.fr/) (latest release).

This is not required for normal usage.

## Structure

These are the different parts of the framework.

**Modules**

- [dao-core]()
- [dao-users]()

**Utilities**

- [dao-stl]()

#### dao-core

The dao-core library contains the core components of the system - Doug and Permission.

#### dao-users

A basic user registry.

#### dao-stl

A library made up of standard contracts that are shared between modules. 

A number of collections such as maps, multi-maps and sets.

## DAO framework?

Yes, this is a framework for DAOs (Decentralized Autonomous Organizations), although one could argue that it is not, because if there are administrator accounts then the organization is not really autonomous. This is correct, but it is *possible* to create autonomous systems, or those that are "somewhat autonomous" (through the use of voting and other mechanisms).

It really works like Ethereum contracts. Ethereum contracts are often called smart-contracts even though they don't have to be smart, and they don't have to be [legal] contracts; the Ethereum protocol can't be used to check if that is indeed what they are. Similarly, the DAO framework lets you create DAOs, but they don't have to be distributed, autonomous, or organizations. You can create a fully managed single user system and deploy it on an offline block-chain node, nothing in this framework will prevent you from doing that, but if you want to create a DAO you can do that too.

## Licence

The entire framework is licensed under MIT.