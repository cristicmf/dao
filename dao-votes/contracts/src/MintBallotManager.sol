import "../../../dao-stl/contracts/src/errors/Errors.sol";
import "../../../dao-core/contracts/src/Doug.sol";
import "../../../dao-users/contracts/src/UserDatabase.sol";
import "../../../dao-currency/contracts/src/MintedCurrency.sol";
import "./BallotMap.sol";
import "./MintBallot.sol";

contract MintBallotManager is BallotMap, DefaultDougEnabled, Errors {

    uint constant DEFAULT_DURATION = 1 days;
    uint8 constant DEFAULT_QUORUM = 50;

    uint _currentId = 1;

    UserDatabase _userDatabase;
    MintedCurrency _mintedCurrency;
    bool _removeClosed;

    function MintBallotManager(address userDatabase, address mintedCurrency, bool removeClosed) {
        _userDatabase = UserDatabase(userDatabase);
        _mintedCurrency = MintedCurrency(mintedCurrency);
        _removeClosed = removeClosed;
    }

    function createBallot(address receiver, uint amount) returns (uint16 error) {
        if (receiver == 0 || amount == 0)
            return NULL_PARAM_NOT_ALLOWED;
        if (!_userDatabase.hasUser(receiver))
            return RESOURCE_NOT_FOUND;
        var id = _currentId++;
        var ballot = new MintBallot(
            id,
            this,
            _userDatabase,
            msg.sender,
            DEFAULT_DURATION,
            DEFAULT_QUORUM,
            _userDatabase.size(),
            receiver,
            amount
        );
        _insert(ballot, 1);
    }

    function mint(address receiver, uint amount) returns (uint16 error) {
        // Check if caller is a registered ballot.
        if (_map._data[msg.sender].value == 0)
            return ACCESS_DENIED;
        // This is a valid call. Clear if flag is set.
        if (_removeClosed)
            _remove(msg.sender);
        else
            _map._data[msg.sender].value = 2;
        // Check that user still exists.
        if (!_userDatabase.hasUser(receiver))
            return RESOURCE_NOT_FOUND;
        // Execute.
        return _mintedCurrency.mint(receiver, amount);
    }

}