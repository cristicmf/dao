/*
    File: PublicMintingBallot.sol
    Author: Andreas Olofsson (androlo1980@gmail.com)
*/
import "dao-votes/src/AbstractPublicBallot.sol";
import "./PublicCurrency.sol";

/*
    Contract: PublicMintingBallot

    Public ballot that mints coins upon successful votes.
*/
contract PublicMintingBallot is AbstractPublicBallot {

    address _receiver;
    uint _amount;

    /*
        Constructor: PublicMintingBallot

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
        Function: ballotType

        Get the type of the ballot.

        Returns:
            ballotType (bytes32) - The ballot type.
    */
    function ballotType() constant returns (bytes32 ballotType) {
        return "minting";
    }

    /*
        Function: receiver

        Get the address of the receiver.

        Returns:
            receiver (address) - The address.
    */
    function receiver() constant returns (address receiver) {
        return _receiver;
    }

    /*
        Function: amount

        Get the amount of coins the receiver will get.

        Returns:
            amount (uint) - The amount.
    */
    function amount() constant returns (uint amount) {
        return _amount;
    }

    /*
        Function: _execute

        Calls 'mint' on the registry (a public currency contract) if a vote succeeds.

        Returns:
            error (uint16) - An error code.
    */
    function _execute() internal returns (uint16 error) {
        return PublicCurrency(_registry).mint(_receiver, _amount);
    }
}