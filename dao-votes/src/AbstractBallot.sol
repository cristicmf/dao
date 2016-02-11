/*
    File: AbstractPublicBallot.sol

    Author: Andreas Olofsson (androlo1980@gmail.com)
*/
import "./Ballot.sol";
import "dao-stl/src/errors/Errors.sol";

/*
    Contract: AbstractBallot

    An abstract implementation of <Ballot>.

    The vote must be concluded manually by calling 'finalize' after the time has expired,
    unless every eligible voter votes (in which case the last vote will automatically
    conclude it).
*/
contract AbstractBallot is Ballot, Errors {

    uint _id;
    address _creator;
    address _registry;

    uint _opened;
    uint _durationInSeconds;
    uint _concluded;

    // This is the error returned by the _execute() function that is run upon a successful vote.
    uint16 _execError;

    // Current state.
    State _state;

    /*
        Constructor: AbstractBallot

        Params:
            id (uint) - The ballot id.
            creator (address) - The account that created the ballot.
            opened (uint) - When the ballot was (will be) opened.
            durationInSeconds (uint) - The duration from when the ballot opened to when it closes, in seconds.
    */
    function AbstractBallot(
        uint id,
        address creator,
        uint opened,
        uint durationInSeconds
    ) {
        _registry = msg.sender;
        _id = id;
        _creator = creator;
        _opened = opened;
        _durationInSeconds = durationInSeconds;
        _state = State.Open;
    }

    /*
        Function: id

        Get the ballot id.

        Returns:
            id (uint) - The id.
    */
    function id() constant returns (uint id){
        return _id;
    }

    /*
        Function: creator

        Get the address of the creator.

        Returns:
            creator (address) - The address of the creator.
    */
    function creator() constant returns (address creator) {
        return _creator;
    }

    /*
        Function: opened

        Get the time when the ballot is/was opened.

        Returns:
            opened (uint) - A unix timestamp.
    */
    function opened() constant returns (uint opened) {
        return _opened;
    }

    /*
        Function: durationInSeconds

        Get the duration of the ballot in seconds.

        Returns:
            durationInSeconds (uint) - The duration of the ballot.
    */
    function durationInSeconds() constant returns (uint durationInSeconds){
        return _durationInSeconds;
    }

    /*
        Function: state

        Get the current state of the ballot. See <State>.

        Returns:
            state (uint8) - The current state.
    */
    function state() constant returns (uint8 state){
        return uint8(_state);
    }

    /*
        Function: concluded

        Get the time when the vote was concluded.

        Returns:
            concluded (uint) - The time when the vote was concluded.
    */
    function concluded() constant returns (uint concluded) {
        return _concluded;
    }

    /*
        Function: execError

        Get the error code returned by the function that was executed as a response to a successful vote.

        Returns:
            execError (uint16) - The error code.
    */
    function execError() constant returns (uint16 execError) {
        return _execError;
    }

    /*
        Function: destroy

        Destroy a contract. No return values since it's a destruction. Calls 'selfdestruct'
        on the contract if successful. Can only be called by the creator of the ballot.
        Fires off a <Destroy> event.

        Params:
            fundReceiver (address) - The account that receives the funds.
    */
    function destroy(address fundReceiver) {
        if (msg.sender == _registry) {
            Destroy(fundReceiver, this.balance, NO_ERROR);
            selfdestruct(fundReceiver);
        }
        else
            Destroy(fundReceiver, 0, ACCESS_DENIED);
    }

}