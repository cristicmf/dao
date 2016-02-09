# dao-votes

## Installation and Usage

#### Building/rebuilding of contracts

NOTE: Requires `solc`.

Shell script: `$ ./build_contracts.sh dao-votes`

Gulp: `$ gulp build:votes`

#### Testing

Gulp: `$ gulp test:votes` 

Command-line tool: `$ solunit -d ./dao-votes/build/test`

#### Usage

[User manual](https://github.com/smartcontractproduction/dao/blob/master/docs/Manual.md)

## Contracts

![DaoCoreContracts](../docs/images/dao-votes-contracts.png)

#### PublicBallot

Public ballot is a complex ballot that allows everyone in entire user-registry to vote. It also has a time-limit, quorum, and other things. 

The ballot is a contract rather then just a struct in its manger, because of how much data it contains. If/when old ballots are removed, it is much easier to just call 'destroy' on a contract then manually removing potentially hundreds or thousands of mapped entries manually.
 
The `PublicBallot` contract is an interface, and there is also an abstract implementation name `AbstractPublicBallot`.

#### BallotMap

An iterable map that can be extended by ballot manager contracts.

#### PublicMintingBallot

A public ballot contract that will call a `mint` function on a given contract if the vote succeeds. The `mint` function is part of the `MintedCurrency` interface in `dao-currency`.

#### PublicDurationBallot

A public ballot contract that will call a `setDuration` function on a given contract if the vote succeeds. This method is part of the `PubliCurrency` contract, and is used to set the duration of ballots.

#### PublicQuorumBallot

A public ballot contract that will call the `setQuorum` function on a given contract if the vote succeeds. This method is part of the `PubliCurrency` contract, and is used to set the percentage of eligible voters that must vote for a vote to pass.

#### PublicKeepDurationBallot

A public ballot contract that will call the `setKeepDuration` function on a given contract if the vote succeeds. This method is part of the `PubliCurrency` contract, and is used to set how much time must pass from a vote being concluded to when it can be removed.

#### PublicCurrency

A minted user currency that Uses public voting for minting, setting vote durations, quorum, and the time before a ballot may be removed from the history.