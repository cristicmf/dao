# Conventions

These are some conventions used throughout this library.

## Solidity

### Code

Official solidity [style guide](http://solidity.readthedocs.org/en/latest/style-guide.html).

* All names are camel-cased. Functions and variables start with a lower case letter, structs, contracts and libraries with an upper case letter. `uint radius`, `int64 xCoord`, `function addInts(int numOne, numTwo)`, `struct Map`, `contract Coin`, `library StringUtils`. The exception is constant variables which written in all-caps, separated by floors, e.g. `MAX_VALUE`, `RESOURCE_NOT_FOUND`.

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

* Contracts generally has interfaces (purely abstract versions). Implementation names usually contain the interface name. Example: A user database interface could be `UserDatabase`, and one that allow users to register themselves could be `SelfRegUserDatabase`.

* Contracts that are not purely abstract usually has the word `Abstract` in front of the contract name, e.g. `AbstractUserDatabase`. They are implementations of interfaces that leaves one or more methods out.

* Contracts that makes use of other contracts normally uses the most abstract representation that is possible.

#### Testing

* Test-contracts are [sol-unit](https://github.com/smartcontractproduction/sol-unit) compatible.

### Javascript

#### Code

No style in particular. Whatever works. Using WebStorm's JSLint functionality when formatting.

#### Libraries

- Using `async` and the `fs-extra` libraries a lot.

- Using `gulp` for most build related stuff.

### Files

* Solidity files are named after the main contract in the file, e.g. if the main contract is `DefaultDoug` then the file is name is `DefaultDoug.sol`.

* Solidity libraries are normally in their own file, and has the ending `slb`. The naming is temporary as there is no standard for this yet.