# changelog

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