# Conventions

This is the conventions used in these libraries. 

## Solidity

### Code

* All names are camelcased. Functions and variables start with a lower case letter, structs, contracts and libraries with an upper case letter. `uint radius`, `int64 xCoord`, `function addInts(int numOne, numTwo)`, `struct Map`, `contract Coin`, `library StringUtils`. The exception is constant variables which written in all-caps, separated by floors, e.g. `MAX_VALUE`, `RESOURCE_NOT_FOUND`.

* The `get` in accessor functions is omitted, e.g. `owner()`, not `getOwner()`.

* `internal` functions and variables has a floor (`_`) in front, `private` ones has two.

* The `public` modifier is not used for variables. Accessor functions are written manually so that they can be documented and return values can be named.

* Functions always returns a value (if nothing else then an error code).

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

These rules are not followed religiously.

#### Testing

* Test-contracts are [sol-unit](https://github.com/smartcontractproduction/sol-unit) compatible. 

### Files

* Solidity files are named after the main contract in the file, e.g. if the main contract is `DefaultDoug` then the file is name is `DefaultDoug.sol`.