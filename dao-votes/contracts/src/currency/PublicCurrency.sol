import "../../../dao-stl/contracts/src/errors/Errors.sol";
import "../../../dao-core/contracts/src/Doug.sol";
import "../../../dao-users/contracts/src/UserDatabase.sol";
import "../../../dao-currency/contracts/src/MintedUserCurrency.sol";
import "./BallotMap.sol";
import "./MintBallot.sol";

/*
    Contract: PublicCurrency

    A 'MintedUserCurrency' that is controlled by <PublicVote> contracts. The ballot register
    is not in a separate contract, since ballots are short-lived, and there really shouldn't
    be any changes to the actual ballot control logic while ballots are taking place.

    Author: Andreas Olofsson (androlo1980@gmail.com)
*/
contract PublicCurrency is BallotMap, MintedUserCurrency, Errors {

    // Constant: DEFAULT_DURATION
    // The ballot-duration used by default (1 day in seconds).
    uint constant DEFAULT_DURATION = 1 days;
    // Constant: DEFAULT_QUORUM
    // The quorum-size used by default (50 %).
    uint8 constant DEFAULT_QUORUM = 50;

    uint _currentId = 1;
    bool _removeClosed;

    /*
        Constructor: PublicCurrency

        Params:
            currencyDatabase (address) - The address to the currency database.
            userDatabase (address) - The address to the user database.
            removeClosed (bool) - Whether to remove ballot contracts when they are closed.
    */
    function PublicCurrency(address currencyDatabase, address userDatabase, bool removeClosed
    ) MintedUserCurrency(currencyDatabase, userDatabase, this) {
        _removeClosed = removeClosed;
    }

    /*
        Function: vote

        Called to cast a vote.

        Params:
            ballotAddress (address) - The address of the ballot contract.
            vote (uint8) - The vote. See <PublicVote.Vote>.

        Returns:
            error (uint16) - An error code.
    */
    function vote(address ballotAddress, uint8 vote) returns (uint16 error) {
        var ballotState = _map._data[ballotAddress].value;
        if (ballotState == 0)
            return RESOURCE_NOT_FOUND;
        if (ballotState != 1)
            return INVALID_STATE;
        return PublicMintingBallot(ballotAddress).vote(msg.sender, vote, block.timestamp);
    }

    /*
        Function: createMintBallot

        Creates a new ballot for minting. If the vote is successful, the 'receiver' will get
        the 'amount' of coins sent to their account.

        Params:
            receiver (address) - The receiver account.
            amount (uint) - The amount.

        Returns:
            error (uint16) - An error code.
    */
    function createMintBallot(address receiver, uint amount) returns (uint16 error) {
        if (receiver == 0 || amount == 0)
            return NULL_PARAM_NOT_ALLOWED;
        if (!_userDatabase.hasUser(receiver))
            return RESOURCE_NOT_FOUND;
        var id = _currentId++;
        var ballot = new PublicMintingBallot(
            id,
            _userDatabase,
            msg.sender,
            block.timestamp,
            DEFAULT_DURATION,
            DEFAULT_QUORUM,
            _userDatabase.size(),
            receiver,
            amount
        );
        // Initial state is always "open".
        _insert(ballot, 1);
    }

    /*
        Function: mintRequest

        Mint new coins and add to an account. The only accounts that can call this successfully are
        those in the ballot registry, meaning the contract will only mint coins upon successful votes.

        Receiver must be registered in the provided 'UserDatabase'.

        Params:
            receiver (address) - The receiver account.
            amount (int) - The amount. Use a negative value to subtract.

        Returns:
            error (uint16) - An error code.
    */
    function mintRequest(address receiver, uint amount) returns (uint16 error) {
        // Check if caller is a registered ballot.
        if (_map._data[msg.sender].value == 0)
            return ACCESS_DENIED;
        // This is a valid call. Clear if flag is set.
        if (_removeClosed)
            _remove(msg.sender);
        else
            _map._data[msg.sender].value = 2;
        return mint(receiver, amount);
    }

}