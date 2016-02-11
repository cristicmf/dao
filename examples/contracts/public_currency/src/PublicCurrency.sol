/*
    File: PublicCurrency.sol
    Author: Andreas Olofsson (androlo1980@gmail.com)
*/
import "dao-stl/src/errors/Errors.sol";
import "dao-core/src/Doug.sol";
import "dao-users/src/UserDatabase.sol";
import "dao-currency/src/MintedUserCurrency.sol";
import "./PublicMintingBallot.sol";
import "./PublicDurationBallot.sol";
import "./PublicQuorumBallot.sol";
import "./PublicKeepDurationBallot.sol";
import "dao-votes/src/BallotMap.sol";
import "dao-votes/src/AbstractPublicYNABallot.sol";

/*
    Contract: PublicCurrency

    A 'MintedUserCurrency' that is controlled by <PublicVote> contracts. The ballot register
    is not in a separate contract, since ballots are short-lived, and there really shouldn't
    be any changes to the actual ballot control logic while ballots are taking place.

*/
contract PublicCurrency is BallotMap, MintedUserCurrency {

    /*
        Event: Vote

        Params:
            ballotAddress (address) - The ballot address.
            vote (uint8) - The vote value.
            error (uint16) - An error code.
    */
    event Vote(address indexed ballotAddress, uint8 indexed vote, uint16 indexed error);

    /*
        Event: CreateMintBallot

        Params:
            receiver (address) - The receiver address.
            amount (uint) - The amount.
            error (uint16) - An error code.
    */
    event CreateMintBallot(address indexed receiver, uint indexed amount, uint16 indexed error);

    /*
        Event: CreateDurationBallot

        Params:
            duration (uint) - The duration.
            error (uint16) - An error code.
    */
    event CreateDurationBallot(uint indexed duration, uint16 indexed error);

    /*
        Event: CreateQuorumBallot

        Params:
            quorum (uint8) - The quorum.
            error (uint16) - An error code.
    */
    event CreateQuorumBallot(uint8 indexed quorum, uint16 indexed error);

    /*
        Event: CreateKeepDurationBallot

        Params:
            keepDuration (uint) - The keep duration.
            error (uint16) - An error code.
    */
    event CreateKeepDurationBallot(uint indexed keepDuration, uint16 indexed error);

    /*
        Event: RemoveBallot

        Params:
            ballotAddress (address) - The address of the ballot.
            error (uint16) - An error code.
    */
    event RemoveBallot(address indexed ballotAddress, uint16 indexed error);

    // Constant: DEFAULT_DURATION
    // The ballot-duration used by default (1 day in seconds).
    uint constant DEFAULT_DURATION = 1 days;
    // Constant: DEFAULT_QUORUM
    // The quorum-size used by default (50 %).
    uint8 constant DEFAULT_QUORUM = 50;

    uint _duration;
    uint8 _quorum;
    uint _keepDuration;

    uint _currentId = 1;

    /*
        Constructor: PublicCurrency

        Params:
            currencyDatabase (address) - The address to the currency database.
            userDatabase (address) - The address to the user database.
    */
    function PublicCurrency(address currencyDatabase, address userDatabase)
        MintedUserCurrency(currencyDatabase, userDatabase, this)
    {
        _duration = DEFAULT_DURATION;
        _quorum = DEFAULT_QUORUM;
        _keepDuration = 1 years;
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
        var ballotState = _ballotMap._data[ballotAddress].value;
        if (ballotState == 0)
            error = RESOURCE_NOT_FOUND;
        else
            error = PublicMintingBallot(ballotAddress).vote(msg.sender, vote, block.timestamp);

        Vote(ballotAddress, vote, error);
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
            error = NULL_PARAM_NOT_ALLOWED;
        else {
            var (u1, u2) = _userDatabase.hasUsers(msg.sender, receiver);
            if (!(u1 && u2))
                error = RESOURCE_NOT_FOUND;
            else {
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
                _insert(ballot, "mint");
            }
        }
        CreateMintBallot(receiver, amount, error);
    }

    /*
        Function: createDurationBallot

        Creates a new ballot for setting a new duration for votes.

        Params:
            duration (uint) - The duration.

        Returns:
            error (uint16) - An error code.
    */
    function createDurationBallot(uint duration) returns (uint16 error) {
        if (duration == _duration)
            error = INVALID_PARAM_VALUE;
        else if (!_userDatabase.hasUser(msg.sender))
            error = RESOURCE_NOT_FOUND;
        else {
            var id = _currentId++;
            var ballot = new PublicDurationBallot(
                id,
                _userDatabase,
                msg.sender,
                block.timestamp,
                DEFAULT_DURATION,
                DEFAULT_QUORUM,
                _userDatabase.size(),
                duration
            );
            _insert(ballot, "duration");
        }
        CreateDurationBallot(duration, error);
    }

    /*
        Function: createQuorumBallot

        Creates a new ballot for setting the quorum.

        Params:
            quorum (uint8) - The quorum. A number between 0 and 100, interpreted as a percentage.

        Returns:
            error (uint16) - An error code.
    */
    function createQuorumBallot(uint8 quorum) returns (uint16 error) {
        if (quorum == _quorum || quorum > 100)
            error = INVALID_PARAM_VALUE;
        else if (!_userDatabase.hasUser(msg.sender))
            error = RESOURCE_NOT_FOUND;
        else {
            var id = _currentId++;
            var ballot = new PublicQuorumBallot(
                id,
                _userDatabase,
                msg.sender,
                block.timestamp,
                DEFAULT_DURATION,
                DEFAULT_QUORUM,
                _userDatabase.size(),
                quorum
            );
            _insert(ballot, "quorum");
        }
        CreateQuorumBallot(quorum, error);
    }

    /*
        Function: createKeepDurationBallot

        Creates a new ballot for setting a new keep-duration for votes.

        Params:
            keepDuration (uint) - The keepDuration.

        Returns:
            error (uint16) - An error code.
    */
    function createKeepDurationBallot(uint keepDuration) returns (uint16 error) {
        if (keepDuration == _keepDuration)
            error = INVALID_PARAM_VALUE;
        else if (!_userDatabase.hasUser(msg.sender))
            error = RESOURCE_NOT_FOUND;
        else {
            var id = _currentId++;
            var ballot = new PublicKeepDurationBallot(
                id,
                _userDatabase,
                msg.sender,
                block.timestamp,
                DEFAULT_DURATION,
                DEFAULT_QUORUM,
                _userDatabase.size(),
                keepDuration
            );
            _insert(ballot, "keepDuration");
        }
        CreateKeepDurationBallot(keepDuration, error);
    }

    /*
        Function: mint

        Mint new coins and add to an account. The only accounts that can call this successfully are
        those in the ballot registry, of the proper ballot type.

        Receiver must be registered in the provided 'UserDatabase'.

        Params:
            receiver (address) - The receiver account.
            amount (int) - The amount. Use a negative value to subtract.

        Returns:
            error (uint16) - An error code.
    */
    function mint(address receiver, uint amount) returns (uint16 error) {
        // Check if caller is a registered ballot.
        if (_ballotMap._data[msg.sender].value != "mint")
            error = ACCESS_DENIED;
        else {
            // Make sure the user is still registered.
            if (!_userDatabase.hasUser(receiver))
                error = RESOURCE_NOT_FOUND;
            else
                error = _currencyDatabase.add(receiver, int(amount));
        }
        Mint(receiver, amount, error);
    }

    /*
        Function: setDuration

        Set a new duration for votes. The only accounts that can call this successfully are
        those in the ballot registry, of the proper ballot type.

        Params:
            duration (uint) - The duration.

        Returns:
            error (uint16) - An error code.
    */
    function setDuration(uint duration) returns (uint16 error) {
        // Check if caller is a registered ballot.
        if (_ballotMap._data[msg.sender].value != "duration")
            error = ACCESS_DENIED;
        else
            _duration = duration;
    }
    
    /*
        Function: setQuorum

        Set a new quorum for votes. The only accounts that can call this successfully are
        those in the ballot registry, of the proper ballot type.

        Params:
            quorum (uint8) - The quorum.

        Returns:
            error (uint16) - An error code.
    */
    function setQuorum(uint8 quorum) returns (uint16 error) {
        // Check if caller is a registered ballot.
        if (_ballotMap._data[msg.sender].value != "quorum")
            error = ACCESS_DENIED;
        else
            _quorum = quorum;
    }

    /*
        Function: setKeepDuration

        Set a new keep-duration for votes. The only accounts that can call this successfully are
        those in the ballot registry, of the proper ballot type.

        Params:
            keepDuration (uint) - The duration.

        Returns:
            error (uint16) - An error code.
    */
    function setKeepDuration(uint keepDuration) returns (uint16 error) {
        // Check if caller is a registered ballot.
        if (_ballotMap._data[msg.sender].value != "keepDuration")
            error = ACCESS_DENIED;
        else
            _keepDuration = keepDuration;
    }

    /*
        Function: removeBallot

        Remove a ballot. The ballot must be concluded, and a certain time must
        have passed (the keepDuration).

        Ballots can be removed by anyone, once the conditions are met.

        Params:
            ballotAddress (address) - The address of the ballot.

        Returns:
            error (uint16) - An error code.
    */
    function removeBallot(address ballotAddress) returns (uint16 error) {
        if (ballotAddress == 0)
            error = NULL_PARAM_NOT_ALLOWED;
        else {
            var ballotType = _ballotMap._data[msg.sender].value;
            if (ballotType == 0)
                error = RESOURCE_NOT_FOUND;
            else {
                var ballot = AbstractPublicYNABallot(ballotAddress);
                var concluded = ballot.concluded();
                if (block.timestamp < concluded + _keepDuration)
                    error = INVALID_STATE;
                else {
                    var (, removed) = _remove(ballotAddress);
                    if (!removed)
                        error = RESOURCE_NOT_FOUND;
                    else
                        ballot.destroy(msg.sender);
                }
            }
        }
        RemoveBallot(ballotAddress, error);
    }

    /*
        Function: duration

        Get the duration.

        Returns:
            duration (uint) - The duration.
    */
    function duration() constant returns (uint duration) {
        return _duration;
    }

    /*
        Function: quorum

        Get the quorum.

        Returns:
            quorum (uint8) - The quorum.
    */
    function quorum() constant returns (uint8 quorum) {
        return _quorum;
    }

    /*
        Function: keepDuration

        Get the time that must pass before a vote can be removed. Time is in seconds.

        Returns:
            keepDuration (uint) - The duration.
    */
    function keepDuration() constant returns (uint keepDuration) {
        return _keepDuration;
    }

}