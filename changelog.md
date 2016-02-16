# changelog

#### 0.1.16

- Updated loading to allow both a web3 instance and a default address as input.

#### 0.1.15

- Minor fixes to deployer, builder, and contract loading functions.

#### 0.1.14

- Added 'builder' and 'solc.compile' to index.js

#### 0.1.13

- Changed contract build-scripts to js-only. Shell scripts are gone.

- Added new deployment output. The output `contracts.json` now includes the compiler version, and the bytecode and ABIs used at the time of deployment.

- When contracts are loaded from a `contracts.json`, the bytecode of the contract at the given address is now compared to the code in the file.

- 'contract.json' files can be amended by providing it as input to new deployments.
 
- It is now possible to `deployLibrary` directly with `Deployer`. It automatically links with dependencies, just like with contracts, but is added to the deployers libraries list rather then the list of contracts. It used to only be possible to deploy contracts, and auto-link libraries.

#### 0.1.12

- Added txData object to all service methods.

- Added javascript deployment and loading methods to dao-users.
 
- Added 'constant' to a method in minted currency, and one in user registry. Re-compiled.

#### 0.1.11

- Minor updates to permissions contract and service.

#### 0.1.10

- Fixed wrong method name in permission service.

#### 0.1.9

- Added better error-reporting.

#### 0.1.8

- Changed output and (some) input in javascript contract services to use objects rather then multiple params. Better for web apis.

- Patched simple_update example so that it now require modules from the correct folders. This was broken after moving from `dao-core` to `examples`.

#### 0.1.7

- Small tweak to DefaultDoug to make contracts overwritable.

#### 0.1.6

- Added the changelog.

- Refactored votes. There is now a `Ballot` and an `AbstractBallot` that the public ballot contracts depends on.

- Moved the `Destructible` contract from `dao-core` to the standard library.

- Added the `Executor` contract to the standard library and separated the functionality out from the `PublicBallot`.

- Added an `examples` folder. Moved the simple contract update javascript there (from `dao-core`), and the public currency contracts (from `dao-votes`).

#### 0.1.5 

- Changed so that all HTML contract docs are in the same place, rather then having one webpage per module.

- Linked all javascript with index file.

- Other updates (bad tracking).

#### 0.1.4

- Many updates (bad tracking).

#### 0.1.3

- Many updates (bad tracking).

#### 0.1.2

- Many updates (bad tracking).

#### 0.1.1

- Many updates (bad tracking).

#### 0.1.0

- Initial release