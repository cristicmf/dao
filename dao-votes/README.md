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

#### Ballot

Ballots are the basic voting contracts used in this system. It comes with an interface version, `Ballot`, and an abstract contract, `AbstractBallot` that implements some of the functions.

#### PublicBallot

A ballot where eligible voters are taken from a `UserDatabase`, and has some additional features like a quorum.

#### YesNoAbstainVote

A vote where the options are yes, no or abstain.

#### BallotMap

An iterable map that can be extended by ballot manager contracts.