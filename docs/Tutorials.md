# Tutorials

- [Basic Tutorial](#basic-tutorial)

##### Case studies

- [Database Providers](#database-providers)

## Basic Tutorial

This tutorial shows how to use the dao framework by making a simple coin. We're going to start from the sub-currency example on the [Solidity webpage](http://solidity.readthedocs.org/en/latest/introduction-to-smart-contracts.html#subcurrency-example). This is how the currency contract looks at the time of writing:

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

This contract has all the basic functionality needed for a sub-currency contract, but it must be modified to fit into the framework.

### Step 1

The first change is to separate it into a database and an actions contract. We will leave the database empty for now, and put everything into the actions contract. 

We will make a few modifications first.

- The event is not needed for this example, so it will be removed. 

- We will remove the public modifier from `minter` and write the accessor function ourselves so that we can document it and name the return value. We will also put a `_` in front of the variable name since it's not public.

- We will do the same thing as above with the `balances` field.

- We will return standard error-codes from non-constant functions. 

- We will make the minter address a constructor argument instead of automatically assigning `msg.sender`.

- We will integrate the contracts with the framework.

NOTE: Ethereum itself does not support return values in transactions yet, but it is a planned feature, and is always useful in contract-to-contract calls.

```
contract CoinDb is DefaultDatabase {

}
```

```
contract CoinActions is DefaultDougEnabled {
    
    address _minter;
    mapping (address => uint) _balances;

    function CoinActions(address minter) {
        _minter = minter;
    }
    
    function mint(address receiver, uint amount) returns (uint16 error) {
        if (msg.sender != _minter) 
            return ACCESS_DENIED;
        _balances[receiver] += amount;
    }
    
    function send(address receiver, uint amount) returns (uint16 error) {
        if (_balances[msg.sender] < amount)
            return INSUFFICIENT_SENDER_BALANCE;
        _balances[msg.sender] -= amount;
        _balances[receiver] += amount;
    }
    
    function minter() constant returns (address minter) {
        return _minter;
    }
    
    function accountBalance(address addr) constant returns (uint balance) {
        return _balances[addr];
    }
    
}
```

`DefaultDougEnabled` makes it possible to add the contract to `Doug`, and `Errors` gives access to a set of standard error-codes.

### Step 2

The next step is to separate logic from data-storage.

```

contract CoinDb is DefaultDatabase {
    
    mapping (address => uint) _balances;

    function CoinDb(bytes32 actionName) DefaultDatabase(actionName) {}

    function add(address receiver, uint amount) returns (uint16 error) {
        if(!_checkCaller())
            return ACCESS_DENIED;
        _balances[receiver] += amount;
    }
    
    function send(address sender, address receiver, uint amount) returns (uint16 error) {
        if(!_checkCaller())
            return ACCESS_DENIED;
        if (_balances[sender] < amount)
            return INSUFFICIENT_SENDER_BALANCE;
        _balances[sender] -= amount;
        _balances[receiver] += amount;
    }
    
    function accountBalance(address addr) constant returns (uint balance) {
        return _balances[addr];
    }
    
}
```

```
contract CoinActions is DefaultDougEnabled {
    
    event Mint(address indexed receiver, uint indexed amount, uint16 indexed error);
    
    event Send(address indexed receiver, uint indexed amount, uint16 indexed error);
    
    address _minter;
    
    CoinDb _cdb;
    
    function CoinActions(address coinDb, address minter) {
        _cdb = CoinDb(coinDb);
        _minter = minter;
    }
        
    function mint(address receiver, uint amount) returns (uint16 error) {
        if (msg.sender != _minter)
            error = ACCESS_DENIED;
        else 
            error = _cdb.add(receiver, amount);
        Mint(receiver, amount, error);
    }
    
    function send(address receiver, uint amount) returns (uint16 error) {
        error = _cdb.send(msg.sender, receiver, amount);
        Send(receiver, amount, error);
    }
    
    function minter() constant returns (address minter) {
        return _minter;
    }
    
}
```

We have now lifted the `minter` mechanics out of the database contract and put it in the actions contract. Minting is restricted to a single account for now.

The database contract has a simple mapping in it, but in a real system we would probably want a more advanced collection. It extends `DefaultDatabase`, which makes it `DougEnabled` and gives it the `_checkCaller`-function, which calls `Doug` to check if the calling contract is an actions-contract.

### Step 3

We now have to deploy the system and test it. We will do that through the browser compiler. Note that the test contract is now the minter and the sender - not us.

```
contract UserProxy {

    function mint(address coinActions, address receiver, uint amount) returns (uint16 error) {
        error = CoinActions(coinActions).mint(receiver,amount);
    }
    
    function send(address coinActions, address receiver, uint amount) returns (uint16 error) {
        error = CoinActions(coinActions).send(receiver,amount);
    }
}


contract CoinTest {
    
    Doug _doug;
    UserProxy _proxy;
    
    function CoinTest() {
        _doug = new DefaultDoug(new DefaultPermission(address(this)), false, false);
        var cdb = new CoinDb("minted_coin");
        _doug.addDatabaseContract("minted_coin", cdb);
        var ca = new CoinActions(cdb, this);
        _doug.addActionsContract("minted_coin", ca);
        _proxy = new UserProxy();
    }
    
    function mint(address receiver, uint amount) returns (uint16) {
        return CoinActions(_doug.actionsContractAddress("minted_coin")).mint(receiver,amount);
    }
    
    function send(address receiver, uint amount) returns (uint16) {
         return CoinActions(_doug.actionsContractAddress("minted_coin")).send(receiver,amount);
    }
    
    function mintAsProxy(address receiver, uint amount) returns (uint16) {
        return _proxy.mint(_doug.actionsContractAddress("minted_coin"), receiver, amount);
    }
    
    function sendAsProxy(address receiver, uint amount) returns (uint16) {
         return _proxy.send(_doug.actionsContractAddress("minted_coin"), receiver, amount);
    }
    
    function balance(address addr) constant returns (uint) {
        return CoinDb(_doug.databaseContractAddress("minted_coin")).accountBalance(addr);
    }
    
    function myAddress() constant returns (address) {
        return address(this);
    }
        
    function proxyAddress() constant returns (address) {
        return address(_proxy);
    }
    
}
```

You may run this yourself in the online compiler by clicking this [link](https://chriseth.github.io/browser-solidity/?gist=https://gist.github.com/androlo/2ac5e8bb13967952d24d). After the page has loaded, find `CoinTest` in the menu to the right, click `create`, and then play around with the methods. 

In the regular dao framework modules the tests are done using the sol-unit library, and interaction would be done through RPC calls to the blockchain client - usually through javascript libraries like web3.js. This is just contract code so it will work in any DApp framework.

NOTE: The entire dao-core is added to the gist because github imports does not work yet. When it does, it will only contain the contracts from the tutorial and import the rest from the dao github repo. Also it will take a while to load the page and compile the code.

## Database Providers

There are several ways in which actions contracts and database contracts can be linked. In the basic and advanced tutorials we are effectively using dependency injection, by passing the address to the database in the constructor of the actions contract.

```
function MintedCoin(address dbAddr, address minter) {
    _cdb = CoinDatabase(dbAddr);
    _minter = minter;
}
```

Calls to the database are done using the `_cdb` variable.

```
function send(address receiver, uint amount) returns (uint16 error) {
    return _cdb.send(msg.sender, receiver, amount);
}
```

This is fast and simple, but there is a problem. What if we want to replace the database? In that case we will have to add a method to the actions contract that allow us to change the database address, and remember to do that when we add a new database.

The setter will have to use permissions as well. One way of doing it would be to allow anyone with the Doug permission to do it.

```
function setCoinDatabase(address newCoinDb) returns (uint16 error) {
    var perm = Permission(_DOUG.permissionAddress());
    if(!perm.hasPermission(msg.sender))
        return ACCESS_DENIED;
    _cdb = CoinDatabase(newCoinDb);
    return NO_ERROR;
}
```

Another alternative is to have the contract discover the database through Doug. All contracts in the system has a reference to Doug, which makes it possible to check the contract registries and permission root/owners. This would have to be done in the `setDougAddress` method as that's when the doug address is set. 

```
function CoinActions(bytes32 databaseId, address minter){
    _databaseId = databaseId;
    _minter = minter;
}

function setDougAddress(address dougAddress) returns (bool) {
    // ...
    var addr = _DOUG.databaseContractAddress(_databaseId);
    if (addr != 0)
        _cdb = CoinDatabase(addr);
}
```

This works just as well, but will cause the same problem as with injection - what if the database is swapped out?

There is only one way of ensuring that the current database is always used, and that is to fetch it every call.

```
function mint(address receiver, uint amount) returns (uint16 error) {
    if (msg.sender != _minter)
        return ACCESS_DENIED;
    var coinDb = CoinDatabase(_DOUG.databaseContractAddress(_databaseId));
    return coinDb.add(receiver, amount);
}
```

This means we can be sure it will always use the latest database, and that we don't have to update manually when changing it. The drawback is that this requires both an additional contract call + Doug has to reach into its iterable map to check, so it adds a small gas overhead to each call. It also can cause issues if the name of the database changes.
 
 Finally, replacing databases should not happen very often. That is one of the main reasons for using database contracts to begin with, so the DI approach makes more sense. It's likely that actions contracts will change, though, and the same principle would apply there.