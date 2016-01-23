# Conventions

These are some conventions used throughout this library.

## Solidity

### Code

Official solidity [style guide](http://solidity.readthedocs.org/en/latest/style-guide.html).

* All names are camel-cased. Functions and variables start with a lower case letter, structs, contracts and libraries with an upper case letter. `uint radius`, `int64 xCoord`, `function addInts(int numOne, numTwo)`, `struct Map`, `contract Coin`, `library StringUtils`. The exception is constant variables which written in all-caps, separated by floors, e.g. `MAX_VALUE`, `RESOURCE_NOT_FOUND`.

* The `get` in accessor functions is omitted, e.g. `owner()`, not `getOwner()`.

* `internal` functions and variables has a floor (`_`) in front, `private` ones has two. `uint _someVar`, `function __fun() private`, `function _intFun() internal`

* The `public` modifier is normally not used for variables. Accessor functions are written manually so that they can be documented and return values can be named.

* Functions always returns a value (if nothing else then an error code). The exception is functions that calls `selfdestruct`.

* Function modifiers are not used since they mess up return values.

Contracts are normally structured like this.

1. Namespaces
2. Constants
3. Enums
4. Struct definitions
5. Events
6. Abstract functions
7. Variables
8. Constructor
9. Functions

Usually interfaces would have the 1-5 parts and implementations 6-8. Functions and variables are usually sorted so that public ones are on top, then internal, then private.

* Contracts generally has interfaces (purely abstract versions). Implementation names usually contain the interface name. Example: A user database interface could be `UserDatabase`, and one that allow users to register themselves could be `SelfRegUserDatabase`.

* Contracts that are not purely abstract usually has the word `Abstract` in front of the contract name, e.g. `AbstractUserDatabase`. They are sometimes implementations of interfaces that leaves a few methods out.

* Contracts that makes use of other contracts normally uses the most abstract version possible.

#### Testing

* Test-contracts are [sol-unit](https://github.com/smartcontractproduction/sol-unit) compatible.

### Javascript

#### Code

No style in particular. Whatever works. Using JSLint.  

#### Libraries

- Using `async` and the `fs-extra` libraries a lot.

- Using `gulp` for most build related stuff.

- Javascript tests will be done using `mocha`.

### Files

* Solidity files are named after the main contract in the file, e.g. if the main contract is `DefaultDoug` then the file is name is `DefaultDoug.sol`.

* Solidity libraries are normally in their own file, and has the ending `slb`. The naming is temporary as there is no standard for this yet.