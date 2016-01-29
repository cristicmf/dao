import "./AbstractPublicBallot.sol";
import "./MintBallotManager.sol";

contract MintBallot is AbstractPublicBallot {

    MintBallotManager _ballotManager;

    address _receiver;
    uint _amount;

    function MintBallot(
        uint id,
        address ballotManager,
        address userDatabase,
        address creator,
        uint durationInSeconds,
        uint8 quorum,
        uint numEligibleVoters,
        address receiver,
        uint amount
    ) AbstractPublicBallot(
        id,
        userDatabase,
        creator,
        durationInSeconds,
        quorum,
        numEligibleVoters
    ) {
        _ballotManager = MintBallotManager(ballotManager);
        _receiver = receiver;
        _amount = amount;
    }

    function _execute() internal returns (uint16 error) {
        return _ballotManager.mint(_receiver, _amount);
    }

}