# DAO manual

## Table of Content

1. Overview
2. Getting started
3. Ðevelopment
4. Ðesign philosophy

This section contains a more detailed description, for developers.

## Overview

![DaoCore](./docs/dao-core.png)

The DAO framework uses three main classes of contracts: Libraries, Databases and Actions.

#### Libraries

Libraries are plain Solidity libraries. These are not considered part of the system like databases and actions contracts because they are not registered with DaoCore, but could be created together with the other contracts when deployed.

#### Databases

Database contracts are bare-bones storage contracts. They contain only the functionality needed to read and write data to storage. The data they work with would usually be structured (though the actual struct definitions may be put in libraries), and would usually have a collection interface like a map or a set.

#### Actions contracts

Actions contracts contains a number of actions that can be taken by users. There could for example be a 'users' actions contract and a corresponding user database. The actions are functions in the actions contract, such as registering, modifying and removing users.

### Contracts

This is a list of the contracts included in the system, with an explanation for each one.

#### Doug

Doug is the top level contract. It has a permissions contract, registries for actions and database contracts, and a number of basic options.

In the default implementation, the creator of Doug supplies the address to an already deployed `Permission` contract in the constructor. Doug will then use that to check if a caller is allowed to add, modify, or remove any of its contracts, or change the properties. By default it will also disallow everything if the permissions contract was not set (i.e. the address is nil).

Doug is divided up into the interface, `Doug`, and th default implementation, `DefaultDoug`. 

#### DougEnabled

`DougEnabled` is an interface that contracts must implement in order to be added to Doug. It .
 
Note that this interface does not guarantee that it is safe to add a contract just because it is doug-enabled, it just makes it easier for developers to create contracts that works with the system.

#### Permission

The permission contract is used to control access to Doug functionality, such as adding and removing contracts, and changing its options. It has an interface, `Permission` and a default implementation, `DefaultPermission`. Doug works with the interface, and allows users with the Doug permission to replace the permission contract itself. This makes it possible to write a custom permission contract and use that instead, so long as it satisfies the interface.

#### Database

`Database` is a contract that extends `DefaultDougEnabled` and adds an internal method for checking that a calling contract is registered as a Doug actions contract. It can be extended by contracts that are registered as databases in the system.

#### Errors

Errors is a contract with a number of error names and codes that is used in 'dao-core` functions (and its other modules).

NOTE: It is quite limited, and will hopefully be replaced with a more standardized one later. Also, it will be changed when constant variables can be declared outside of contracts, so that the contract doesn't have to be extended.


### DAO permissions model

There are three main types of access in this system:

1. **Root access**. This is managed by Doug, and handles permissions to add and remove contracts from the system, and changing core properties like whether or not contracts can be overwritten, and replacing the core premissions management system itself.

2. **Database access**. The system automatically gives actions-contracts write access to all registered databases.
    
3. **User access**. This includes access to all actions except those that involves Doug. The application maker is in full control over these permissions. It could be handled per-contract or on a system wide basis (or both).

## Getting started

TODO

## Ðevelopment

This section contains a more detailed description, for developers.

TODO

## Ðesign philosophy

The purpose of the dao-core is to provide a solid base for advanced systems of Ethereum contracts. The goal is to make the system:

- Efficient. Should not add extra database bloat or slow things down unnecessarily.

- Flexible. You should be able to replace components when they become outdated, or bugs are discovered.

- Reliable. The system should be secure, which means it should be protected against attacks as well as mistakes made by users and developers.

Striking a good balance can be difficult, as it is in all types of programs. The three things I believe affects these things the most is how gas, contract-calling, and the database works.

**Gas**

Gas is used to pay for both processing power and database storage on the public Ethereum chain, because every full node has to execute all transactions, and store all the data. The gas cost for each VM instruction can be found in the table on page 20 of the [Ethereum Yellow Paper](http://gavwood.com/paper.pdf).

It's worth noting that as of 2016-01-10, simple operations (push to stack, add, multiply, etc.) costs 1 single gas, but writing one word (up to 32 bytes of data) costs 20000. This means contract optimization can be summed up by two words - **AVOID STORAGE**. Things you can do is to avoid collections that requires extra data per element, instantiating new contracts, and if a function stores user data it should normally be careful with un-bounded strings and arrays.

**Contract calling**

Contracts that has been added to the Ethereum chain can be transacted to by anyone, which means that anyone can invoke the functions they expose. If a function invocation involves write operations you will normally start by checking if the caller has permission to do it. This could be done for example by pre-registering an account as the administrator (or owner), and then check if the caller is that account. This is an example:
 

```
contract SelfDestructible {
    
    address _owner;
    
    function SelfDestructible(address owner) {
        _owner = owner;
    }
    
    function destroy() {
        if (msg.sender == _owner) selfdestruct(_owner);
    }
    
}

contract IncrediblyUseful is SelfDestructible {
    
    function IncrediblyUseful() SelfDestructible(msg.sender) {}
    
}
```

In this case, a contract that extends `SelfDestructible` will have a `destroy` function for self destruction. This function is public, and can be invoked by anyone, but unless their address is the same as `owner`, it will not pass the guard and nothing will happen. For example, in the  `IncrediblyUseful` contract (which can do nothing but self-destruct), the owner would always be the account that created the contract.

**The database**

Ethereum contracts have access to a database so that they can persist the values of their fields between calls. The big problem is that the storage of a contract can only be accessed by the code in that contract - which is immutable. If there are bugs in the code, or you need to add new functionality, you can't just update it, restart, and keep going; you have to create an entirely new contract. The old contract will still have the data in it though, and you still have to go through the old code to make changes to that data.

The purpose of the database and actions contract separation is to work around this limitation. Database contracts would normally work like basic collections, and have provide very basic interfaces to read, write and modify data. Additionally, they only need to do one very simple check to see if the caller has the right permission. Admittedly it will cost a bit more gas then when everything is lumped together into one contract, but the cost is in most cases negligible (a few hundred gas).


It's worth pointing out that a lot of the difficulties with databases doesn't come with basic usage. "I can test my contract to see if it works, why would it all over sudden break???". That is a bad question, because most contracts that are part of a system will depend on other contracts - most importantly the ones that handles account permissions. A call-chain could start with a user calling a contract, which in turn make a series of intra-system contract-to-contract calls, and each one of those calls will have to be safe. Changing one contract could affect several others and the effects can sometimes be hard to predict, and errors can sometimes be irreversible.

#### Avoiding complexity

The DAO framework has a clear separation between its different components. The `dao-core` library, for example, requires only two contracts to be deployed (Doug, Permissions) - because that's all it needs.

This I believe encourages developers to write modular code, like they would in any other language.

#### A note on public and private chains

The dao-core is designed with public chains in mind, but not the public Ethereum chain. This is mostly due to gas. The gas system is really designed to regulate the public Ethereum chain, and in practice it really only allow trivial systems because of how restrictive it is. At least for now. An application-specific side-chain would have fewer contracts in it and less data to store, meaning it could have lower costs for gas and a higher max gas limit in blocks. 

When it comes to private chains, i.e. chains that are managed by a single entity that does all the validation, I don't think there is a strong use case for the dao-core. If the chain is private and application specific, the proprietor might as well include the smart-contract logic in the client itself and save themselves all of the EVM overhead (and having to work in a new and somewhat difficult language). The usefulness of private chains (if any) is still being debated, and lots of research is going on, but I can't see any good use-case other then experimentation, or to prepare before the system is eventually put on a public (or some kind of semi-public) chain.

For these reasons, the dao suite may evolve into two different versions; one for big systems, and a hyper-optimized mini version for the public Ethereum chain.
