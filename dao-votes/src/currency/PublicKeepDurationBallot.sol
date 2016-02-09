/*
    File: PublicKeepDurationBallot.sol
    Author: Andreas Olofsson (androlo1980@gmail.com)
*/
import "dao-votes/src/AbstractPublicBallot.sol";
import "./PublicCurrency.sol";

/*
    Contract: PublicKeepDurationBallot

    Public ballot that sets vote durations upon successful votes.
*/
contract PublicKeepDurationBallot is AbstractPublicBallot {

    uint _keepDuration;

    /*
        Constructor: PublicKeepDurationBallot

        Params:
            id (uint) - The ballot id.
            userDatabase (address) - The address to the user database.
            creator (address) - The account that created the ballot.
            opened (uint) - When the ballot was (will be) opened.
            durationInSeconds (uint) - The duration from when the ballot opened to when it closes, in seconds.
            quorum (uint8) - A number between 0 and 100 (inclusive). Used as a percentage.
            numEligibleVoters (uint) - The number of eligible voters at the time of creation.
            keepDuration (uint) - The keep-duration.
    */
    function PublicKeepDurationBallot(
        uint id,
        address userDatabase,
        address creator,
        uint opened,
        uint durationInSeconds,
        uint8 quorum,
        uint numEligibleVoters,
        uint keepDuration
    ) AbstractPublicBallot(
        id,
        userDatabase,
        creator,
        opened,
        durationInSeconds,
        quorum,
        numEligibleVoters
    ) {
        _keepDuration = keepDuration;
    }

    /*
        Function: ballotType

        Get the type of the ballot.

        Returns:
            ballotType (bytes32) - The ballot type.
    */
    function ballotType() constant returns (bytes32 ballotType) {
        return "keepDuration";
    }

    /*
        Function: keepDuration

        Get the keep duration.

        Returns:
            keepDuration (uint) - The new duration.
    */
    function keepDuration() constant returns (uint keepDuration) {
        return _keepDuration;
    }

    /*
        Function: _execute

        Calls 'setDuration' on the registry (a public currency contract) if a vote succeeds.

        Returns:
            error (uint16) - An error code.
    */
    function _execute() internal returns (uint16 error) {
        return PublicCurrency(_registry).setKeepDuration(_keepDuration);
    }

}