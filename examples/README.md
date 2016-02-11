# examples

This folder contains examples of how the framework can be used.

### Public Currency

The public currency is an example of how the contracts can be used. It is a `MintedUserCurrency` where minting is controlled by public voting (as well as the voting process itself).

The currency makes use of all modules:

- `dao-core` for governing the entire system.

- `dao-users` for controlling who gets to vote. Voters must be registered users.

- `dao-currency` for the minted currency. The public currency contract extends `MintedUserCurrency` but sets itself as the minter.

- `dao-votes` for the ballots. The public currency contract extends `BallotMap`, manages ballots through it, and the ballots are created from the base contracts in votes.

### Simple Update

Simple update is javascript for creating a Doug system, adding a test contract and then replacing it.

The point of this is to give an example of how the contracts can actually be managed. The procedure would be this:

1. Start an ethereum node.

2. Run `deploy-one`, to deploy doug, permissions contract, simple database contract, and the first of the simple actions contracts.

3. Run `simple-test` to try writing a value to the database via the actions contract. It should succeed.

4. Run `deploy-two`, which will deploy the second simple actions contract and replace the first one in Doug.

5. Run `simple-test` again. 