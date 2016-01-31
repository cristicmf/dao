import "../AbstractPublicBallot.sol";
import "./PublicCurrency.sol";

/*
    Contract: PublicMintingBallot

    Public ballot that mints coins upon successful votes.

    Author: Andreas Olofsson (androlo1980@gmail.com)
*/
contract PublicMintingBallot is AbstractPublicBallot {

    PublicCurrency _publicCurrency;

    address _receiver;
    uint _amount;

    /*
        Constructor: AbstractPublicBallot

        Params:
            id (uint) - The ballot id.
            userDatabase (address) - The address to the user database.
            creator (address) - The account that created the ballot.
            opened (uint) - When the ballot was (will be) opened.
            durationInSeconds (uint) - The duration from when the ballot opened to when it closes, in seconds.
            quorum (uint8) - A number between 0 and 100 (inclusive). Used as a percentage.
            numEligibleVoters (uint) - The number of eligible voters at the time of creation.
            receiver (address) - The receiver of the minted coins.
            amount (uint) - The amount of coins to be minted.
    */
    function PublicMintingBallot(
        uint id,
        address userDatabase,
        address creator,
        uint opened,
        uint durationInSeconds,
        uint8 quorum,
        uint numEligibleVoters,
        address receiver,
        uint amount
    ) AbstractPublicBallot(
        id,
        userDatabase,
        creator,
        opened,
        durationInSeconds,
        quorum,
        numEligibleVoters
    ) {
        _receiver = receiver;
        _amount = amount;
    }

    /*
        Function: _execute

        Calls 'mintRequest' on the registry (a public currency contract) if a vote succeeds.

        Returns:
            error (uint16) - An error code.
    */
    function _execute() internal returns (uint16 error) {
        return PublicCurrency(_registry).mintRequest(_receiver, _amount);
    }

}