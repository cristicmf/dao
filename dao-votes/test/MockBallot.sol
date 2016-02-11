import "dao-votes/src/AbstractBallot.sol";

contract MockBallot is AbstractBallot {

    uint16 constant MB_RETURN = 0x2121;

    function MockBallot(
        uint id,
        address creator,
        uint opened,
        uint durationInSeconds
    ) AbstractBallot(
        id,
        creator,
        opened,
        durationInSeconds
    ) {}

    function ballotType() constant returns (bytes32 ballotType) {
        return "mock";
    }

    function _execute() internal returns (uint16 error) {
        return MB_RETURN;
    }

    function numEligibleVoters() constant returns (uint numEligibleVoters) {}

    function numVotes() constant returns (uint numVotes) {}

}