import "./BallotManager.sol";

contract PublicBallotManager is BallotManager {

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
        Event: Vote

        Params:
            ballotId (uint) - The ballot Id.
            vote (uint8) - The vote. See <Vote>.
            error (uint16) - Error code for the function.
    */
    event Vote(uint indexed ballotId, uint8 indexed vote, uint16 indexed error);


    /*
        Event: Finalize

        Params:
            passed (bool) - Whether or not the vote passed.
            error (uint16) - Error code for the function.
            execError (uint16) - Error code for the action triggered by the vote.
    */
    event Finalize(uint indexed ballotId, bool indexed passed, uint16 indexed error, uint16 execError);

    /*
        Function: vote

        Called to cast a vote.

        Params:
            ballotId (uint) - The ballot Id.
            vote (uint8) - The vote. See <Vote>.

        Returns:
            error (uint16) - An error code.
    */
    function vote(uint ballotId, uint8 vote) returns (uint16 error);

    /*
        Function: finalize

        Called to finalize a vote.

        Params:
            ballotId (uint) - The ballot Id.

        Returns:
            passed (bool) - Whether or not the vote passed.
            error (uint16) - Error code for the function.
            execError (uint16) - Error code for the action triggered by the vote.
    */
    function finalize(uint ballotId) returns (bool passed, uint16 error, uint16 execError);

    /*
        Function: voteData

        Get voter data from their account address.

        Params:
            ballotId (uint) - The ballot Id.
            index (uint) - The index.

        Returns:
            vote (uint8) - The vote. See <Vote>.
            error (uint16) - An error code.
    */
    function voterData(uint ballotId, address voterAddress) constant returns (uint8 vote, uint16 error);

    /*
        Function: voteDataFromIndex

        Get voter data from their index in the backing array. Used for iterating.

        Params:
            ballotId (uint) - The ballot Id.
            index (uint) - The index.

        Returns:
            addr (address) - The voter address.
            vote (uint8) - The vote. See <Vote>.
            error (uint16) - An error code.
    */
    function voterDataFromIndex(uint ballotId, uint index) constant returns (address addr, uint8 vote, uint16 error);

    /*
        Function: result

        Get the result of the vote.

        Params:
            ballotId (uint) - The ballot Id.

        Returns:
            result (int) - The result of the vote.
    */
    function result(uint ballotId) constant returns (int result);

    /*
        Function: execError

        Get the error code returned by the function that was executed as a response to a successful vote.

        Params:
            ballotId (uint) - The ballot Id.

        Returns:
            execError (uint16) - The error code.
    */
    function execError(uint ballotId) constant returns (uint16 execError);

    /*
        Function: quorum

        Get the quorum. It is a number between 0 and 100, used as a percentage in calculations.

        Params:
            ballotId (uint) - The ballot Id.

        Returns:
            quorum (uint16) - The quorum.
    */
    function quorum(uint ballotId) constant returns (uint16 quorum);


    /*
        Function: userDatabase

        Get the address of the user database.

        Params:
            ballotId (uint) - The ballot Id.

        Returns:
            userDatabase (address) - The address.
    */
    function userDatabase(uint ballotId) constant returns (address userDatabase);


}