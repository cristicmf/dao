import "dao-votes/src/AbstractPublicYNABallot.sol";

contract MockPublicYNABallot is AbstractPublicYNABallot {

    uint16 constant MPB_RETURN = 0x2222;

    function MockPublicYNABallot(
        uint id,
        address userDatabase,
        address creator,
        uint opened,
        uint durationInSeconds,
        uint8 quorum,
        uint numEligibleVoters
    ) AbstractPublicYNABallot(
        id,
        userDatabase,
        creator,
        opened,
        durationInSeconds,
        quorum,
        numEligibleVoters
    ) {}

    function ballotType() constant returns (bytes32 ballotType) {
        return "mockPublicYNA";
    }

    function _execute() internal returns (uint16 error) {
        return MPB_RETURN;
    }

}