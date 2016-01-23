import "../../../dao-stl/src/errors/Errors.sol";
import "../../../dao-users/contracts/src/UserDatabase.sol";

contract PublicBallot is Errors {

    enum State {Null, Open, Closed}

    enum Vote {Null, Yes, No, Abstain}

    struct Element {
        uint _keyIndex;
        uint8 _value;
    }

    struct Map
    {
        mapping(address => Element) _data;
        address[] _keys;
    }

    // Needs to be implemented.
    function _execute() internal returns (uint16 error);

    UserDatabase _userDatabase;

    uint _id;
    address _creator;

    uint _opened;
    uint _durationInSeconds;

    uint _numEligibleVoters;
    int _result;

    // Current state.
    State _state;

    // This is the error returned by the _execute() function that is run upon a successful vote.
    uint16 _execError;
    uint8 _quorum;

    Map _votes;

    function PublicBallot(
        uint id,
        address userDatabase,
        address creator,
        uint durationInSeconds,
        uint8 quorum,
        uint numEligibleVoters
    ) {
        _id = id;
        _userDatabase = UserDatabase(userDatabase);
        _creator = creator;
        _durationInSeconds = durationInSeconds;
        _quorum = quorum;
        _numEligibleVoters = numEligibleVoters;
        _opened = block.timestamp;
        _state = State.Open;
    }

    function vote(uint8 vote) returns (uint16 error){

        // Ballot is closed.
        if (_state != State.Open)
            return INVALID_STATE;
        // Time for voting is up.
        if (block.timestamp > _opened + _durationInSeconds)
            return INVALID_STATE;

        var voteElem = _votes._data[msg.sender];
        // User already voted.
        if (voteElem._value != 0)
            return RESOURCE_ALREADY_EXISTS;

        var (, userJoined,) = _userDatabase.user(msg.sender);

        // Don't let users vote unless they are registered, and registration happened before the ballot started.
        if (userJoined == 0 || userJoined > _opened)
            return ACCESS_DENIED;

        var v = Vote(vote);
        if (v == Vote.Yes || v == Vote.No || v == Vote.Abstain) {
            int voteVal;
            if (v == Vote.Yes)
                voteVal == 1;
            else if (v == Vote.No)
                voteVal == -1;
            _result += voteVal;
            var keyIndex = _votes._keys.length++;
            _votes._keys[keyIndex] = msg.sender;
            _votes._data[msg.sender] = Element(keyIndex, vote);
            // If every potential voter has voted, auto execute.
            if (_votes._keys.length == _numEligibleVoters)
                _execute();
        }
        else {
            return INVALID_PARAM_VALUE;
        }
    }

    function finalize() returns (bool passed, uint16 error, uint16 execError) {
        // Voting was already finalized.
        if (_state != State.Open){
            error = INVALID_STATE;
            return;
        }
        // The only requirement for a vote to be finalized is that the time has passed.
        if (block.timestamp <= _opened + _durationInSeconds) {
            error = INVALID_STATE;
            return;
        }
        // If a quorum is set and not enough people voted.
        if (_quorum != 0 && (_votes._keys.length * 100) / _numEligibleVoters < _quorum) {
            error = INVALID_STATE;
            return;
        }
        _state = State.Closed;
        // If vote failed. Note it needs a majority of yes votes to succeed.
        if (_result <= 0)
            return;
        _execError = execError = _execute();
        passed = true;
    }

    function voteDataFromIndex(uint index) internal constant returns (address addr, uint8 vote, uint16 error) {
        if (index >= _votes._keys.length) {
            error = ARRAY_INDEX_OUT_OF_BOUNDS;
            return;
        }
        addr = _votes._keys[index];
        vote = _votes._data[addr]._value;
    }

    function id() constant returns (uint id){
        return _id;
    }

    function userDatabase() constant returns (address userDatabase){
        return _userDatabase;
    }

    function durationInSeconds() constant returns (uint durationInSeconds){
        return _durationInSeconds;
    }

    function numEligibleVoters() constant returns (uint numEligibleVoters){
        return _numEligibleVoters;
    }

    function result() constant returns (int result){
        return _result;
    }

    function state() constant returns (uint8 state){
        return uint8(_state);
    }

    function execError() constant returns (uint16 execError){
        return _execError;
    }

    function quorum() constant returns (uint16 quorum){
        return _quorum;
    }

    function numVotes() constant returns (uint numVotes){
        return _votes._keys.length;
    }

}