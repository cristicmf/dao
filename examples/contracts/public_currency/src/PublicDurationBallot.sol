/*
    File: PublicDurationBallot.sol
    Author: Andreas Olofsson (androlo1980@gmail.com)
*/
import "dao-votes/src/AbstractPublicYNABallot.sol";

import "./PublicCurrency.sol";

/*
    Contract: PublicDurationBallot

    Public ballot that sets vote durations upon successful votes.
*/
contract PublicDurationBallot is AbstractPublicYNABallot {

    uint _newDuration;

    /*
        Constructor: PublicDurationBallot

        Params:
            id (uint) - The ballot id.
            userDatabase (address) - The address to the user database.
            creator (address) - The account that created the ballot.
            opened (uint) - When the ballot was (will be) opened.
            durationInSeconds (uint) - The duration from when the ballot opened to when it closes, in seconds.
            quorum (uint8) - A number between 0 and 100 (inclusive). Used as a percentage.
            numEligibleVoters (uint) - The number of eligible voters at the time of creation.
            duration (uint) - The duration.
    */
    function PublicDurationBallot(
        uint id,
        address userDatabase,
        address creator,
        uint opened,
        uint durationInSeconds,
        uint8 quorum,
        uint numEligibleVoters,
        uint newDuration
    ) AbstractPublicYNABallot(
        id,
        userDatabase,
        creator,
        opened,
        durationInSeconds,
        quorum,
        numEligibleVoters
    ) {
        _newDuration = newDuration;
    }

    /*
        Function: ballotType

        Get the type of the ballot.

        Returns:
            ballotType (bytes32) - The ballot type.
    */
    function ballotType() constant returns (bytes32 ballotType) {
        return "duration";
    }

    /*
        Function: newDuration

        Get the new duration.

        Returns:
            newDuration (uint) - The new duration.
    */
    function newDuration() constant returns (uint newDuration) {
        return _newDuration;
    }

    /*
        Function: _execute

        Calls 'setDuration' on the registry (a public currency contract) if a vote succeeds.

        Returns:
            error (uint16) - An error code.
    */
    function _execute() internal returns (uint16 error) {
        return PublicCurrency(_registry).setDuration(_newDuration);
    }

}