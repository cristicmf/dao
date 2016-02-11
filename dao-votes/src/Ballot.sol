/*
    File: Ballot.sol

    Author: Andreas Olofsson (androlo1980@gmail.com)
*/
import "dao-core/src/Doug.sol";
import "dao-stl/src/contracts/Executor.sol";

/*
    Contract: PublicBallot

    An interface contract for ballots.
*/
contract Ballot is Executor, Destructible {

    /*
        Enum: State

        The state of the voting contract.

        Null - Null state.

        Open - The ballot is open.

        Closed - The ballot is closed.

        Error - Something happened that put the ballot in an error state.
    */
    enum State {Null, Open, Closed, Error}

    /*
        Function: ballotType

        Get the type of the ballot.

        Returns:
            ballotType (bytes32) - The ballot type.
    */
    function ballotType() constant returns (bytes32 ballotType);

    /*
        Function: id

        Get the ballot id.

        Returns:
            id (uint) - The id.
    */
    function id() constant returns (uint id);

    /*
        Function: creator

        Get the address of the creator.

        Returns:
            creator (address) - The address of the creator.
    */
    function creator() constant returns (address creator);

    /*
        Function: opened

        Get the time when the ballot is/was opened.

        Returns:
            opened (uint) - A unix timestamp.
    */
    function opened() constant returns (uint opened);

    /*
        Function: durationInSeconds

        Get the duration of the ballot in seconds.

        Returns:
            durationInSeconds (uint) - The duration of the ballot.
    */
    function durationInSeconds() constant returns (uint durationInSeconds);

    /*
        Function: state

        Get the current state of the ballot. See <State>.

        Returns:
            state (uint8) - The current state.
    */
    function state() constant returns (uint8 state);

    /*
        Function: numEligibleVoters

        Get the number of eligible voters.

        Returns:
            numEligibleVoters (uint) - The number of eligible voters.
    */
    function numEligibleVoters() constant returns (uint numEligibleVoters);

    /*
        Function: numVotes

        Get the current number of votes.

        Returns:
            numVotes (uint) - The current number of votes.
    */
    function numVotes() constant returns (uint numVotes);

    /*
        Function: concluded

        Get the time when the vote was concluded.

        Returns:
            concluded (uint) - The time when the vote was concluded.
    */
    function concluded() constant returns (uint concluded);

}