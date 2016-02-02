/*
    Contract: PublicBallot

    An interface contract for public ballots. This is a very complex vote
    that requires its own contract. It allows for any number of voters.
    Simpler voting contracts done by a handful of voters can be done wih a
    struct + library combination instead.

    Author: Andreas Olofsson (androlo1980@gmail.com)
*/
contract PublicBallot {

    /*
        Enum: State

        The state of the voting contract.


        Null - Null state.

        Open - The ballot is open.

        Closed - The ballot is closed.
    */
    enum State {Null, Open, Closed}

    /*
        Enum: Vote

        An enumeration of different vote values.


        Null - Null vote.

        Yes - A yes vote.

        No - A no vote.

        Abstain - An abstain vote.
    */
    enum Vote {Null, Yes, No, Abstain}

    /*
        Event: Finalize

        Params:
            passed (bool) - Whether or not the vote passed.
            error (uint16) - Error code for the function.
            execError (uint16) - Error code for the action triggered by the vote.
    */
    event Finalize(bool indexed passed, uint16 indexed error, uint16 indexed execError);

    /*
        Function: vote

        Called to cast a vote.

        Params:
            voter (address) - The voter address.
            vote (uint8) - The vote. See <Vote>.
            timestamp (uint) - The time when the vote is made.

        Returns:
            error (uint16) - An error code.
    */
    function vote(address voter, uint8 vote, uint timestamp) returns (uint16 error);

    /*
        Function: finalize

        Called to finalize a vote.

        Returns:
            passed (bool) - Whether or not the vote passed.
            error (uint16) - Error code for the function.
            execError (uint16) - Error code for the action triggered by the vote.
    */
    function finalize() returns (bool passed, uint16 error, uint16 execError);

    /*
        Function: voteData

        Get voter data from their account address.

        Params:
            index (uint) - The index.

        Returns:
            vote (uint8) - The vote. See <Vote>.
            error (uint16) - An error code.
    */
    function voterData(address voterAddress) constant returns (uint8 vote, uint16 error);

    /*
        Function: voteDataFromIndex

        Get voter data from their index in the backing array. Used for iterating.

        Params:
            index (uint) - The index.

        Returns:
            addr (address) - The voter address.
            vote (uint8) - The vote. See <Vote>.
            error (uint16) - An error code.
    */
    function voterDataFromIndex(uint index) constant returns (address addr, uint8 vote, uint16 error);

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
        Function: userDatabase

        Get the address of the user database.

        Returns:
            userDatabase (address) - The address.
    */
    function userDatabase() constant returns (address userDatabase);

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
        Function: numEligibleVoters

        Get the number of eligible voters.

        Returns:
            numEligibleVoters (uint) - The number of eligible voters.
    */
    function numEligibleVoters() constant returns (uint numEligibleVoters);

    /*
        Function: result

        Get the result of the vote.

        Returns:
            result (int) - The result of the vote.
    */
    function result() constant returns (int result);

    /*
        Function: state

        Get the current state of the ballot. See <State>.

        Returns:
            state (uint8) - The current state.
    */
    function state() constant returns (uint8 state);

    /*
        Function: execError

        Get the error code returned by the function that was executed as a response to a successful vote.

        Returns:
            execError (uint16) - The error code.
    */
    function execError() constant returns (uint16 execError);

    /*
        Function: quorum

        Get the quorum. It is a number between 0 and 100, used as a percentage in calculations.

        Returns:
            quorum (uint16) - The quorum.
    */
    function quorum() constant returns (uint16 quorum);

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

    /*
        Function: _execute

        Internal function that should be called upon a successful vote.

        Returns:
            error (uint16) - An error code.
    */
    function _execute() internal returns (uint16 error);

}