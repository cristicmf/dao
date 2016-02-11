import "public-currency/src/PublicMintingBallot.sol";
import "public-currency/src/PublicDurationBallot.sol";
import "public-currency/src/PublicQuorumBallot.sol";
import "public-currency/src/PublicKeepDurationBallot.sol";
import "dao-votes/src/YesNoAbstainVote.sol";


contract MockPublicCurrency {

    uint16 constant MPC_RETURN = 0x333;

    address _receiver;
    uint _amount;
    uint _duration;
    uint _keepDuration;
    uint8 _quorum;

    address _ballot;

    function createMintingBallot(
        uint id,
        address userDatabase,
        address creator,
        uint opened,
        uint durationInSeconds,
        uint8 quorum,
        uint numEligibleVoters,
        address receiver,
        uint amount
    ) constant returns (address addr) {
        addr = new PublicMintingBallot(
                id,
                userDatabase,
                creator,
                opened,
                durationInSeconds,
                quorum,
                numEligibleVoters,
                receiver,
                amount
            );
        _ballot = addr;
    }

    function createDurationBallot(
        uint id,
        address userDatabase,
        address creator,
        uint opened,
        uint durationInSeconds,
        uint8 quorum,
        uint numEligibleVoters,
        uint newDuration
    ) constant returns (address addr) {
        addr = new PublicDurationBallot(
                id,
                userDatabase,
                creator,
                opened,
                durationInSeconds,
                quorum,
                numEligibleVoters,
                newDuration
            );
        _ballot = addr;
    }

    function createQuorumBallot(
        uint id,
        address userDatabase,
        address creator,
        uint opened,
        uint durationInSeconds,
        uint8 quorum,
        uint numEligibleVoters,
        uint8 newQuorum
    ) constant returns (address addr) {
        addr = new PublicQuorumBallot(
                id,
                userDatabase,
                creator,
                opened,
                durationInSeconds,
                quorum,
                numEligibleVoters,
                newQuorum
            );
        _ballot = addr;
    }

    function createKeepDurationBallot(
        uint id,
        address userDatabase,
        address creator,
        uint opened,
        uint durationInSeconds,
        uint8 quorum,
        uint numEligibleVoters,
        uint keepDuration
    ) constant returns (address addr) {
        addr = new PublicKeepDurationBallot(
                id,
                userDatabase,
                creator,
                opened,
                durationInSeconds,
                quorum,
                numEligibleVoters,
                keepDuration
            );
        _ballot = addr;
    }

    function vote(address voter, uint8 vote, uint timestamp) returns (uint16 error) {
        return YesNoAbstainVote(_ballot).vote(voter, vote, timestamp);
    }

    function mint(address receiver, uint amount) returns (uint16 error) {
        _receiver = receiver;
        _amount = amount;
        return MPC_RETURN;
    }

    function getMintingData() constant returns (address receiver, uint amount) {
        return (_receiver, _amount);
    }

    function setDuration(uint duration) returns (uint16 error) {
        _duration = duration;
        return MPC_RETURN;
    }

    function duration() constant returns (uint duration) {
        return _duration;
    }

    function setQuorum(uint8 quorum) returns (uint16 error) {
        _quorum = quorum;
        return MPC_RETURN;
    }

    function quorum() constant returns (uint8 quorum) {
        return _quorum;
    }

    function setKeepDuration(uint keepDuration) returns (uint16 error) {
        _keepDuration = keepDuration;
        return MPC_RETURN;
    }

    function keepDuration() constant returns (uint keepDuration) {
        return _keepDuration;
    }

}