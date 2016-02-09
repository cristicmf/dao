/*
    File: PublicQuorumBallot.sol
    Author: Andreas Olofsson (androlo1980@gmail.com)
*/
import "dao-votes/src/AbstractPublicBallot.sol";
import "./PublicCurrency.sol";

/*
    Contract: PublicQuorumBallot

    Public ballot that sets the quorum upon successful votes.
*/
contract PublicQuorumBallot is AbstractPublicBallot {

    uint8 _newQuorum;

    /*
        Constructor: PublicQuorumBallot

        Params:
            id (uint) - The ballot id.
            userDatabase (address) - The address to the user database.
            creator (address) - The account that created the ballot.
            opened (uint) - When the ballot was (will be) opened.
            durationInSeconds (uint) - The duration from when the ballot opened to when it closes, in seconds.
            quorum (uint8) - A number between 0 and 100 (inclusive). Used as a percentage.
            numEligibleVoters (uint) - The number of eligible voters at the time of creation.
            newQuorum (uint8) - The new quorum.
    */
    function PublicQuorumBallot(
        uint id,
        address userDatabase,
        address creator,
        uint opened,
        uint durationInSeconds,
        uint8 quorum,
        uint numEligibleVoters,
        uint8 newQuorum
    ) AbstractPublicBallot(
        id,
        userDatabase,
        creator,
        opened,
        durationInSeconds,
        quorum,
        numEligibleVoters
    ) {
        _newQuorum = newQuorum;
    }

    /*
        Function: ballotType

        Get the type of the ballot.

        Returns:
            ballotType (bytes32) - The ballot type.
    */
    function ballotType() constant returns (bytes32 ballotType) {
        return "quorum";
    }

    /*
        Function: newQuorum

        Get the quorum.

        Returns:
            newQuorum (uint8) - The quorum.
    */
    function newQuorum() constant returns (uint8 newQuorum) {
        return _newQuorum;
    }

    /*
        Function: _execute

        Calls 'setQuorum' on the registry (a public currency contract) if a vote succeeds.

        Returns:
            error (uint16) - An error code.
    */
    function _execute() internal returns (uint16 error) {
        return PublicCurrency(_registry).setQuorum(_newQuorum);
    }

}