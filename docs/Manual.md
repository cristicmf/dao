# DAO manual

## Table of Content

1. [Overview](#overview)
2. [Basic Tutorial](#basic-tutorial)
2. [Advanced Tutorial](#advanced-tutorial)
3. [Ðevelopment](#develop)
4. [Ðesign philosophy](#design)

## Overview

![DaoCore](./dao-core.png)

The DAO framework uses three main classes of contracts: Libraries, Databases and Actions.

#### Libraries

Libraries are plain Solidity libraries. These are not considered part of the system like databases and actions contracts because they are not registered with DaoCore, but they could be created together with the other contracts when a system is deployed.

#### Databases

Database contracts are bare-bones storage contracts. They contain only the functionality needed to read and write data to storage. The data they work with would usually be structured (though the actual struct definitions may be put in libraries), and they would usually have a collection interface, like a map or a set.

#### Actions contracts

Actions contracts contains a number of actions that can be taken by users. There could for example be a 'users' actions contract and a corresponding user database. The actions are functions in the actions contract and could do anything, like for example registering, modifying and removing users.

### DAO permissions model

There are three main types of access in this system:

1. **Root access**. This is managed by Doug, and handles permissions to add and remove contracts from the system, and changing core properties like whether or not contracts can be overwritten, and replacing the core premissions management system itself.

2. **Database access**. The system automatically gives actions-contracts write access to all the registered databases.
    
3. **User access**. This includes access to all actions except those that involves Doug. The application maker is in full control over these permissions. It could be handled per-contract or on a system wide basis (or both).

### Core contracts

These are the most important contracts in the core library (dao-core).

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

`Database` is a contract that extends `DefaultDougEnabled` and adds an internal method for checking if the calling contract is registered as a Doug actions contract. It can be extended by contracts that are registered as databases in the system.

#### Errors

Errors is a contract with a number of error names and codes that is used in 'dao-core` functions (and its other modules).

NOTE: It is quite limited, and will hopefully be replaced with a more standardized one later. Also, it will be changed when constant variables can be declared outside of contracts, so that the contract doesn't have to be extended.


## Basic Tutorial

This tutorial shows how to use the dao framework. We're going to start by looking at a regular, simple contract; namely the subcurrency example from the [Solidity webpage](http://solidity.readthedocs.org/en/latest/introduction-to-smart-contracts.html#subcurrency-example). This is how it looks at the time of writing:

```
contract Coin {

    // The keyword "public" makes those variables
    // readable from outside.
    address public minter;
    mapping (address => uint) public balances;

    // Events allow light clients to react on
    // changes efficiently.
    event Sent(address from, address to, uint amount);

    // This is the constructor whose code is
    // run only when the contract is created.
    function Coin() {
        minter = msg.sender;
    }
    
    function mint(address receiver, uint amount) {
        if (msg.sender != minter) return;
        balances[receiver] += amount;
    }
    
    function send(address receiver, uint amount) {
        if (balances[msg.sender] < amount) return;
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        Sent(msg.sender, receiver, amount);
    }
}
```

This contract has all the basic functionality needed for a subcurrency contract, but it is not fit for the dao framework. We need to separate it into a database and an actions contract. The reasons will become clear later.

### Step 1

The first step is to create a database and an actions contract. We will leave the database empty for now, and put everything into the actions contract. 

We will make a few modifications first. 

- The event is not needed for this example, so it will be removed. 

- We will remove the public modifier from `minter` and write the accessor function ourselves so that we can document it and name the return value. Also, sticking to the coding conventions, we will put a `_` in front of the variable name since it's not public. This helps us avoid name collisions with functions, and signals to other ÐApp Ðevs that they should never access the variable directly. 

- We will do the same thing as above with the `balances` field.

- We will add return values to all functions, so that callers knows what's going on. These are standard errors so the errors in dao-core's `Errors.sol` will do.

- We will make the minter address a constructor argument instead of automatically assigning `msg.sender`.

```
contract CoinDb is Database {

}
```

```
contract CoinActions is DefaultDougEnabled, Errors {
    
    address _minter;
    mapping (address => uint) _balances;

    function Coin(address minter) {
        _minter = minter;
    }
    
    function mint(address receiver, uint amount) returns (uint16 error) {
        if (msg.sender != minter) {
            return ACCESS_DENIED;
        }
        balances[receiver] += amount;
    }
    
    function send(address receiver, uint amount) returns (uint16 error) {
        if (balances[msg.sender] < amount) {
            return INSUFFICIENT_SENDER_BALANCE;
        }
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
    }
    
    function minter() constant returns (address minter){
        return _minter;
    }
    
    function balance(address addr) constant returns (uint balance){
        return _balances[addr];
    }
    
}
```

### Step 2

The next step is to separate permissions logic from the data storage. User permission checks in the DAO framework are always done in actions contracts.

```
contract CoinDb is Database, Errors {

    
    mapping (address => uint) _balances;

    function Coin() {}
    
    function add(address receiver, uint amount) returns (uint16 error) {
        if(!_checkCaller()){
            return ACCESS_DENIED;
        }
        _balances[receiver] += amount;
    }
    
    function send(address sender, address receiver, uint amount) returns (uint16 error) {
        if(!_checkCaller()){
            return ACCESS_DENIED;
        }
        if (_balances[sender] < amount) {
            return INSUFFICIENT_SENDER_BALANCE;
        }
        _balances[sender] -= amount;
        _balances[receiver] += amount;
    }
    
    function accountBalance(address addr) constant returns (uint balance){
        return _balances[addr];
    }
    
}

```

```
contract CoinActions is DefaultDougEnabled, Errors {
    
    address _minter;
    
    CoinDb _cdb;
    
    function CoinActions(address coinDb, address minter){
        _cdb = CoinDb(coinDb);
        _minter = minter;
    }
        
    function mint(address receiver, uint amount) returns (uint16 error) {
        if (msg.sender != _minter) {
            return ACCESS_DENIED;
        }
        return _cdb.add(receiver, amount);
    }
    
    function send(address receiver, uint amount) returns (uint16 error) {
        return _cdb.send(msg.sender, receiver, amount);
    }
    
    function minter() constant returns (address minter){
        return _minter;
    }
        
}
```

We have now lifted the `minter` mechanics out of the database contract and put it in the actions contract instead. Minting is restricted to a single account for now, but if we wanted to add minting privileges to more then one account we can now do that by replacing the action contract; the coin balances of all users would still remain in the database, un-changed.

The database contract only has a simple mapping in it, but in a real system we would probably want a more advanced collection, so there would be a lot more code in there (or it would delegate some of that functionality to a library contract).

Note that the actions contract takes the coin database contract address as a constructor argument. We will look at a number of different ways of doing this in the advanced tutorial.

### Step 3

We now have to deploy the system and test it. We will do that through the browser compiler, to make it as simple as possible. Also, note that the test contract is now the minter, and the sender in all transfers - not us.

```
contract CoinTest {
    
    Doug _doug;
    
    function CoinTest(){
        _doug = new DefaultDoug(new DefaultPermission(address(this)), false);
        var cdb = new CoinDb();
        _doug.addDatabaseContract("coin", cdb);
        var ca = new CoinActions(cdb, this);
        _doug.addActionsContract("minted_coin", ca);
    }
    
    function mint(address receiver, uint amount) returns (bool){
        var err = CoinActions(_doug.actionsContractAddress("minted_coin")).mint(receiver,amount);
        return err == 0;
    }
    
    function send(address receiver, uint amount) returns (bool){
         var err = CoinActions(_doug.actionsContractAddress("minted_coin")).send(receiver,amount);
    }
    
    function balance(address addr) constant returns (uint) {
        return CoinDb(_doug.databaseContractAddress("coin")).accountBalance(addr);
    }
    
}
```

What we did here was to set the system up so that we call it from a solidity contract. This is just to make testing simpler. In a normal system, this would be done from a custom web-page or a server (through RPC calls to the ethereum client).

## Advanced Tutorial

This tutorial builds on the basic tutorial, where we created and deployed a subcurrency using the DAO framework. We are now going to add a user management system that will work together with the currency. Users will no longer be able to just get and transfer money around, but will have to be identified first. 

There are two ways to go about this; one is to add a set of administrators that will vet users off-chain before they are added to the system. It could also be made so that users can register themselves automatically. We will start with the automatic approach.

The way this will work together with the subcurrency contract is that users must be registered in order to send or receive coins. Let's start by adding the user manager database. It allows people to register their account and add a nickname.

```
contract UserDb is Database, Errors {

    mapping (address => bytes32) _usersByAddress;
    mapping (bytes32 => address) _usersByName;
    
    function register(address addr, bytes32 name) returns (uint16 error) {
        if(!_checkCaller()){
            return ACCESS_DENIED;
        }
        if(_usersByAddress[addr] != 0 || _usersByName[name] != 0){
            return RESOURCE_ALREADY_EXISTS;
        }
        _usersByAddress[addr] = name;
        _usersByName[name] = addr;
    }
    
    function deregister(address addr) returns (uint16 error) {
        if(!_checkCaller()){
            return ACCESS_DENIED;
        }
        if(_usersByAddress[addr] == 0){
            return RESOURCE_NOT_FOUND;
        }
        _usersByAddress[addr] = name;
        _usersByName[name] = addr;
    }
    
    function userAddress(bytes32 name) constant returns (address userAddress){
        return _usersByName[name];
    }
    
    function userName(address addr) constant returns (bytes32 name){
        return _usersByAddress[addr];
    }
    
    function usersExist(address user1, address user2) constant returns (bool user1Exists, bool user2Exists){
        user1Exists = _usersByAddress[user1] != 0;
        user2Exists = _usersByAddress[user2] != 0;
    }
    
}

```

```
contract UserActions is DefaultDougEnabled, Errors {
    
    address _admin;
    
    UserDb _udb;
    
    function UserActions(address userDb, address admin){
        _udb = UserDb(coinDb);
        _admin = admin;
    }
        
    function register(bytes32 name) returns (uint16 error) {
        if(name == null){
            return NULL_PARAM_NOT_ALLOWED;
        }
        return _udb.register(msg.sender, name);
    }
    
    function deregister() returns (uint16 error) {
        return _udb.deregister(msg.sender);
    }
    
    function deregister(address addr) returns (uint16 error) {
        if(addr != msg.sender && msg.sender != _admin){
            return ACCESS_DENIED;
        }
        return _udb.deregister(addr);
    }
        
    function admin() constant returns (address admin){
        return _admin;
    }
    
}
```

This module is very basic. It lets actions-contracts register and deregister users. Note that some input validation is done in the actions contract and some in the database. The rule of thumb is that if the validation is done using the data inside the database (such as checking if a user is already in the database), it is best done there.

There are two methods for de-registering users, one that takes no parameter and defaults to `msg.sender`, and another one that takes the address as a param. The second one is for adminstrators who wants to remove users that perhaps has an inappropriate name, or that needs to be removed for some other reason.

Notice that there is an existence check for a pair of users. The reason is because interaction between two registered users would usually be a common thing, so it's good to have a function for quickly checking existence of two users at once (i.e. without having to do two separate calls). 

### Step 2

Next we're going to modify the old coin actions contract. It will now check if the caller is a registered user before letting them send or receive coins. Good thing the coin actions contract is separate from the database, or we would have had to replace the entire system; now we only have to fix the actions contract and re-deploy.

contract NewCoinActions is DefaultDougEnabled, Errors {
    
    address _minter;
    
    CoinDb _cdb;
    UserDb _udb;
    
    function CoinActions(address coinDb, address userDb, address minter){
        _cdb = CoinDb(coinDb);
        _udb = UserDb(userDb);
        _minter = minter;
    }
        
    function mint(address receiver, uint amount) returns (uint16 error) {
        if (msg.sender != _minter) {
            return ACCESS_DENIED;
        }
        if(receiver != _minter && _udb.userName(receiver) == 0){
            return RESOURCE_NOT_FOUND;
        }
        return _cdb.add(receiver, amount);
    }
    
    function send(address receiver, uint amount) returns (uint16 error) {
        var (sE, rE) = _udb.usersExist(msg.sender, receiver);
        if(!(sE && rE)){
            return RESOURCE_NOT_FOUND;
        }
        return _cdb.send(msg.sender, receiver, amount);
    }
    
    function minter() constant returns (address minter){
        return _minter;
    }
        
}

The subcurrency module now depends on the user module, because it calls on the user database to do checks before any coins can be minted or transferred. Note that the minter does not have to be a user, so the user check in the mint method needs to take that into account (hence the first condition).

### Step 3

Before we go on to test this, we will consider the performance impact of this setup. Let's start by analyzing the call-chain when someone invokes 'send'. It would look like this.

1. User calls Coin actions
2. Coin actions calls user database (to do user existence check)
3. Coin actions calls coin database (to alter the balances)
4. Coin database calls DOUG (to check if caller is an actions contract)

This means every time a user wants to transfer coins, three contract-to-contract calls will be made. That in itself is not that bad, because a call costs only 40 gas as of now (2016-01-11), but it also involves packing and sending data back and forth so will probably add at least 1000 gas or so to the total. What we could do is to merge steps 2 and 3 by combining the user and coin databases into one, but that is not completely without risk. 

If all we do is combine the two databases so one could check if a user is registered and what their coin balance is at the same time, then that wouldn't be so bad. That's just an accessor function, and if at some point we want to decouple the two components we can still do that - just stop doing that function in actions contracts. 

If want to automatically check user status **when writing**, i.e. as part of the send function in the database contract, then we're stuck with it until we choose to replace the entire database because that would be the only way to change it back.

This is a good example of why the separation is important. Not having it could lead to hard problems. Maybe in some systems it's worth saving a few hundred gas by lumping everything together, but generally that is not the case. At least not in my experience. A send here involves a transaction plus the altering of two storage slots, and only that costs at least 31000 (21k for tx and 5k per storage slot manipulation). 

A better solution could be to allow bulk operations (through arrays), like checking X users, and doing X sends at once. The memory used for that is cheap, and would make sends cost less on average.

### Step 4

Keeping the system as it is for now, this is what we end up with as a testing contract:

TODO

<a name="develop"></a>
## Ðevelopment

This section contains a more detailed description, for developers.

TODO

<a name="design"></a>
## Ðesign philosophy

The purpose of the dao-core is to provide a solid base for advanced systems of Ethereum contracts. The goal is to make the system:

- Efficient. Should not add extra database bloat or slow things down unnecessarily.

- Flexible. You should be able to replace components when they become outdated, or bugs are discovered.

- Reliable. The system should be secure, which means it should be protected against attacks as well as mistakes made by users and developers.

Striking a good balance can be difficult, as it is in all types of programs. It requires some insight into how the gas system, contract-calling, and the database works.

**Gas**

Gas is used to pay for both processing power and database storage on the public Ethereum chain, because every full node has to execute all transactions, and store all the data. The gas cost for each VM instruction can be found in the table on page 20 of the [Ethereum Yellow Paper](http://gavwood.com/paper.pdf).

It's worth noting that as of 2016-01-10, simple operations (push to stack, add, multiply, etc.) costs 1 single gas, but writing one word (up to 32 bytes of data) costs 20000. This means contract optimization can be summed up by two words - **AVOID STORAGE**. Things you can do is to avoid collections that requires extra data per element, instantiating new contracts, and if a function stores user data it should normally be careful with un-bounded strings and arrays.

**Contract calling**

Contracts that has been added to the Ethereum chain can be transacted to by anyone, which means that anyone can invoke the functions they expose. If a function invocation involves write operations you will normally start by checking if the caller has the permission to run it. This could be done for example by pre-registering an account as the administrator (or owner), and then check if the caller is that account. This is an example:
 

``` javascript
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

Ethereum contracts have access to a database so that they can persist the values of their fields between calls. The big problem is that the storage of a particular contract can only be accessed by the code in that contract, and that code is immutable. If there are bugs in the code, or you need to add new functionality, you can't just update it, restart, and keep going; you have to create an entirely new contract. The old contract will still have the data in it though, and you still have to go through the old code to make changes to that data.

The reason for this is that it allows for trust-less systems. If the code is immutable, and the rules are set in advance, then it is possible to create contracts that can be called by anyone without them having to worry about any changes. This is great for oracles and other things.

The purpose of the database and actions contract separation is to work around this limitation. Certain contracts have to be managed, for example those that involve transfers of valuable assets, where users has to know that the actions they and others take are legally binding.

Database contracts would normally work like very basic collections and provide an interface for reading, writing and modifying the data. Additionally, they only need to do one simple check to see if the caller has the right permission. Admittedly it will cost a bit more gas then when everything is lumped together into one contract, but the cost is in most cases negligible (a few hundred gas).

Finally, It's worth pointing out that a lot of the difficulties with contracts doesn't come with basic usage. "I can test my contract to see if it works, why would it all over sudden break???". That is a bad question, because most contracts that are part of a system will depend on other contracts - most importantly the ones that handles account permissions - and some would likely be replaceable. A call-chain could start with a user calling a contract, which in turn leads to a series of intra-system contract-to-contract calls. Changing one of those contract could have effects on the others, and those effects can sometimes be hard to predict. It may also be that some of the effects are irreversible.

#### Avoiding complexity

The DAO framework has a clear separation between its different components. The `dao-core` library, for example, requires only two contracts to be deployed (Doug, Permissions) - because that's all it needs.

This I believe encourages developers to write modular code, like they would in any other language.

#### A note on public and private chains

The dao-core is designed with public chains in mind, but not the public Ethereum chain. This is mostly due to gas. The purpose of the gas system is to regulate the public Ethereum chain, and in practice it only allow trivial systems because of how restrictive it is. At least for now. An application-specific side-chain would have fewer contracts in it and less data to store, meaning it could have lower gas costs and a higher max limit in blocks. 

When it comes to private chains, i.e. chains that are managed by a single entity that does all the validation, I don't think there is a strong use case for the dao framework. If the chain is private and application specific, the proprietor might as well include the smart-contract logic in the client itself and save themselves all of the EVM overhead (and having to work in a new and somewhat difficult language). The usefulness of private chains (if any) is still being debated, and lots of research is going on, but I can't see any good use-case other then experimentation, or to prepare before the system is eventually put on a public (or some kind of semi-public) chain.

For these reasons, the dao framework may evolve into two different versions; one for big systems, and a hyper-optimized mini version for the public Ethereum chain.
