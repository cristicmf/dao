import "./PublicBallot.sol";
import "./MintBallotManager.sol";

contract MintBallot is PublicBallot {

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
    ) PublicBallot(
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