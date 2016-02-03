# Conventions

These are some conventions used throughout this library.

## Solidity

### Code

Official solidity [style guide](http://solidity.readthedocs.org/en/latest/style-guide.html).

* All names are camel-cased. Functions and variables start with a lower case letter, events, structs, contracts and libraries with an upper case letter. `uint radius`, `int64 xCoord`, `function addInts(int numOne, numTwo)`, `struct Map`, `contract Coin`, `library StringUtils`. The exception is constant variables which written in all-caps, separated by floors, e.g. `MAX_VALUE`, `RESOURCE_NOT_FOUND`.

* The `get` in accessor functions is omitted, e.g. `owner()`, not `getOwner()`.

* `internal` functions and variables has a floor (`_`) in front, `private` ones has two.  `uint _someVar`, `function __fun() private`, `function _intFun() internal`.

* Struct members are sometimes have the `_` as well, if the value should never be modified except through a function. The `_` avoids name collisions when using `using`, and also works sort of like it does in javascript: even though you _can_ modify the value, you shouldn't.

```
struct MapElement {
    uint _keyIndex;
    address userAddress;
    string userNickname;
}
```

(`_keyIndex` in this case would be modified by map functions when elements are inserted and removed, and should not be modified manually)

* The `public` modifier is normally not used for variables. Accessor functions are written manually so that they can be documented and return values can be named.

* Functions always returns a value (if nothing else then an error code). The exception is functions that calls `selfdestruct`.

* Function modifiers are not used since they don't play well with return values.

* Events normally has the same name as the function they are called in except with the first letter capitalized, e.g. `function setData` - `event SetData`. If an event is called in many functions it normally has a name that explains what it does.

* Event params are normally some or all of the input and output parameters of the function it is fired in, including the returned error code.

* Contracts generally has interfaces (purely abstract versions). Implementation names usually contain the interface name. Example: A user database interface could be `UserDatabase`, and one that allow users to register themselves could be `SelfRegUserDatabase`.

* Contracts that are not purely abstract usually has the word `Abstract` in front of the contract name, e.g. `AbstractUserDatabase`. They are implementations of interfaces that leaves one or more methods out.

* Contracts that makes use of other contracts normally uses the most abstract representation possible (often an interface).

#### Testing

* Test-contracts are [sol-unit](https://github.com/smartcontractproduction/sol-unit) compatible.

### Javascript

#### Code

No style in particular. Whatever works. Using WebStorm's JSLint functionality when formatting.

#### Contract services

* Contracts are wrapped by contract services that inherits from `contract_service`. 

* Contract services waits for transactions to complete using the appropriate solidity event for the function.

* Contract services returns the data from constant functions in their callback, formatted and with a separate parameter for each, starting with the error. `function(error, userName, userEmail, code)`

* Error codes are always returned as a javascript number. The big number conversion must be done in the contract service before returning it.

* Dates/timestamps are always passed in as a javascript Date object, and returned as Date objects as well. They are stored on-chain as unix timestamps in hex form (as usual).
  
* Durations are generally stored in seconds, and is passed in and out as numbers/bigNumbers depending on the expected size (should almost always be a normal number).

* Numbers in general are passed in as numbers, or BigNumbers, and returned as a BigNumber.

* Addresses are passed in and returned as hex-strings.

* Strings are passed in and returned as hex-strings.

* `byte32` params are passed and returned as normal, unless ASCII is implied. In that case, the contract service must do the conversions so that the function accepts and returns ASCII strings (in these particular cases).

#### Libraries

* Using `async` and the `fs-extra` libraries a lot.

* Using `gulp` for most build related stuff.

### Files

* Solidity files are named after the main contract in the file, e.g. if the main contract is `DefaultDoug` then the file is name is `DefaultDoug.sol`.

* Solidity libraries are normally in their own file, and has the ending `slb`. The naming is temporary as there is no standard for this yet.