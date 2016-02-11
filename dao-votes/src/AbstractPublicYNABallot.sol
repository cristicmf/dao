/*
    File: AbstractPublicYNABallot.sol

    Author: Andreas Olofsson (androlo1980@gmail.com)
*/
import "./PublicBallot.sol";
import "./YesNoAbstainVote.sol";
import "./AbstractBallot.sol";
import "dao-users/src/UserDatabase.sol";

/*
    Contract: AbstractPublicYNABallot

    An abstract implementation of <PublicBallot> using <YesNoAbstain>-votes.

    The vote must be concluded manually by calling 'finalize' after the time has expired,
    unless every eligible voter votes (in which case the last vote will automatically
    conclude it).
*/
contract AbstractPublicYNABallot is AbstractBallot, PublicBallot, YesNoAbstainVote {


    /*
        Struct: Element

        Element type for the voter map.

        Members:
            _keyIndex - Used for iteration.
            value - The vote value (see <PublicBallot.Vote>
    */
    struct Element {
        uint _keyIndex;
        uint8 value;
    }

    /*
        Struct: Map

        Map of voters.

        Members:
            _data - A mapping of 'address' to 'Element's.
            _keys - An array with all keys.
    */
    struct Map
    {
        mapping(address => Element) _data;
        address[] _keys;
    }

    UserDatabase _userDatabase;

    uint _numEligibleVoters;
    int _result;

    uint8 _quorum;

    Map _votes;

    /*
        Constructor: AbstractPublicYNABallot

        Params:
            id (uint) - The ballot id.
            userDatabase (address) - The address to the user database.
            creator (address) - The account that created the ballot.
            opened (uint) - When the ballot was (will be) opened.
            durationInSeconds (uint) - The duration from when the ballot opened to when it closes, in seconds.
            quorum (uint8) - A number between 0 and 100 (inclusive). Used as a percentage.
            numEligibleVoters (uint) - The number of eligible voters at the time of creation.
    */
    function AbstractPublicYNABallot(
        uint id,
        address userDatabase,
        address creator,
        uint opened,
        uint durationInSeconds,
        uint8 quorum,
        uint numEligibleVoters
    ) AbstractBallot(
        id,
        creator,
        opened,
        durationInSeconds
    ) {
        _userDatabase = UserDatabase(userDatabase);
        _quorum = quorum;
        _numEligibleVoters = numEligibleVoters;
    }

    /*
        Function: vote

        Called to cast a vote.

        Params:
            voter (address) - The voter address.
            vote (uint8) - The vote. See <PublicVote.Vote>.
            timestamp (uint) - The time when the vote is made.

        Returns:
            error (uint16) - An error code.
    */
    function vote(address voter, uint8 vote, uint timestamp) returns (uint16 error) {

        if (msg.sender != _registry)
            return ACCESS_DENIED;

        // Ballot is closed.
        if (_state != State.Open)
            return INVALID_STATE;

        // Time for voting is up.
        if (timestamp > _opened + _durationInSeconds)
            return INVALID_STATE;

        var voteElem = _votes._data[voter];

        // User already voted.
        if (voteElem.value != 0)
            return RESOURCE_ALREADY_EXISTS;

        var (, userJoined,) = _userDatabase.user(voter);

        // Don't let users vote unless they are registered, and registration happened before the ballot started.
        if (userJoined == 0 || userJoined > _opened)
            return ACCESS_DENIED;

        var v = Vote(vote);
        if (v == Vote.Yes || v == Vote.No || v == Vote.Abstain) {
            int voteVal;
            if (v == Vote.Yes)
                voteVal = 1;
            else if (v == Vote.No)
                voteVal = -1;
            // Modify the vote value.
            _result += voteVal;
            // Add to list of voters.
            _votes._data[voter] = Element(_votes._keys.push(voter) - 1, vote);
            // If every potential voter has voted, auto execute. To get here, the quorum check is
            // automatically passed (100% of voters voted), state must be 'Open', and time must be fine.
            if (_votes._keys.length == _numEligibleVoters) {
                _state = State.Closed;
                _concluded = block.timestamp;
                // If vote failed. Note it needs a majority of yes votes to succeed.
                if (_result <= 0)
                    return;
                _execError = _execute();
            }
        }
        else
            return INVALID_PARAM_VALUE;
    }

    /*
        Function: finalize

        Called to finalize a vote.

        Returns:
            passed (bool) - Whether or not the vote passed.
            error (uint16) - Error code for the function.
            error (uint16) - Error code for the action triggered by the vote.
    */
    function finalize() returns (bool passed, uint16 error, uint16 execError) {
        // Voting was already finalized.
        if (_state != State.Open)
            error = INVALID_STATE;
        // The only requirement for a vote to be finalized is that the time has passed.
        else if (block.timestamp <= _opened + _durationInSeconds)
            error = INVALID_STATE;
        // If a quorum is set and not enough people voted.
        else if (_quorum != 0 && (_votes._keys.length * 100) / _numEligibleVoters < _quorum)
            error = ERROR;
        else {
            _state = State.Closed;
            _concluded = block.timestamp;
            // If vote failed. Note it needs a majority of yes votes to succeed.
            if (_result > 0) {
                _execError = execError = _execute();
                passed = true;
            }
        }
        Finalize(passed, error, execError);
    }

    /*
        Function: voteData

        Get voter data from their account address.

        Params:
            index (uint) - The index.

        Returns:
            vote (uint8) - The vote. See <PublicVote.Vote>.
            error (uint16) - An error code.
    */
    function voterData(address voterAddress) constant returns (uint8 vote, uint16 error) {
        vote = _votes._data[voterAddress].value;
        if (vote == 0)
            error = RESOURCE_NOT_FOUND;
    }

    /*
        Function: voteDataFromIndex

        Get voter data from their index in the backing array. Used for iterating.

        Params:
            index (uint) - The index.

        Returns:
            addr (address) - The voter address.
            vote (uint8) - The vote. See <PublicVote.Vote>.
            error (uint16) - An error code.
    */
    function voterDataFromIndex(uint index) constant returns (address addr, uint8 vote, uint16 error) {
        if (index >= _votes._keys.length) {
            error = ARRAY_INDEX_OUT_OF_BOUNDS;
            return;
        }
        addr = _votes._keys[index];
        vote = _votes._data[addr].value;
    }

    /*
        Function: userDatabase

        Get the address of the user database.

        Returns:
            userDatabase (address) - The address.
    */
    function userDatabase() constant returns (address userDatabase){
        return _userDatabase;
    }

    /*
        Function: numVotes

        Get the current number of votes.

        Returns:
            numVotes (uint) - The current number of votes.
    */
    function numVotes() constant returns (uint numVotes){
        return _votes._keys.length;
    }

    /*
        Function: numEligibleVoters

        Get the number of eligible voters.

        Returns:
            numEligibleVoters (uint) - The number of eligible voters.
    */
    function numEligibleVoters() constant returns (uint numEligibleVoters){
        return _numEligibleVoters;
    }

    /*
        Function: result

        Get the result of the vote.

        Returns:
            result (int) - The result of the vote.
    */
    function result() constant returns (int result){
        return _result;
    }

    /*
        Function: quorum

        Get the quorum. It is a number between 0 and 100, used as a percentage in calculations.

        Returns:
            quorum (uint16) - The quorum.
    */
    function quorum() constant returns (uint16 quorum){
        return _quorum;
    }

}