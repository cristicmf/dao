import "../../../../dao-core/contracts/src/Doug.sol";

contract BallotManager is DougEnabled {

    /*
        Enum: State

        The state of the voting contract.

        Null - Null state.

        Open - The ballot is open.

        Closed - The ballot is closed.
    */
    enum State {Null, Open, Closed}

    /*
        Function: ballotType

        Get the type of the ballot.

        Returns:
            ballotType (bytes32) - The ballot type.
    */
    function ballotType() constant returns (bytes32 ballotType);

    /*
        Function: creator

        Get the address of the ballot creator.

        Params:
            ballotId (uint) - The ballot Id.

        Returns:
            creator (address) - The address of the creator.
    */
    function creator(uint ballotId) constant returns (address creator);

    /*
        Function: opened

        Get the time when the ballot is/was opened.

        Params:
            ballotId (uint) - The ballot Id.

        Returns:
            opened (uint) - A unix timestamp.
    */
    function opened(uint ballotId) constant returns (uint opened);

    /*
        Function: durationInSeconds

        Get the duration of the ballot in seconds.

        Params:
            ballotId (uint) - The ballot Id.

        Returns:
            durationInSeconds (uint) - The duration of the ballot.
    */
    function durationInSeconds(uint ballotId) constant returns (uint durationInSeconds);

    /*
        Function: numEligibleVoters

        Get the number of eligible voters.

        Params:
            ballotId (uint) - The ballot Id.

        Returns:
            numEligibleVoters (uint) - The number of eligible voters.
    */
    function numEligibleVoters(uint ballotId) constant returns (uint numEligibleVoters);

    /*
        Function: state

        Get the current state of the ballot. See <State>.

        Params:
            ballotId (uint) - The ballot Id.

        Returns:
            state (uint8) - The current state.
    */
    function state(uint ballotId) constant returns (uint8 state);


    /*
        Function: numVotes

        Get the current number of votes.

        Params:
            ballotId (uint) - The ballot Id.

        Returns:
            numVotes (uint) - The current number of votes.
    */
    function numVotes(uint ballotId) constant returns (uint numVotes);

    /*
        Function: concluded

        Get the time when the vote was concluded.

        Params:
            ballotId (uint) - The ballot Id.

        Returns:
            concluded (uint) - The time when the vote was concluded.
    */
    function concluded(uint ballotId) constant returns (uint concluded);

}