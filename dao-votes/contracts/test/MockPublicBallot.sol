import "../src/AbstractPublicBallot.sol";

contract MockPublicBallot is AbstractPublicBallot {

    uint16 constant MPB_RETURN = 0x2222;

    function MockPublicBallot(
        uint id,
        address userDatabase,
        address creator,
        uint opened,
        uint durationInSeconds,
        uint8 quorum,
        uint numEligibleVoters
    ) AbstractPublicBallot(
        id,
        userDatabase,
        creator,
        opened,
        durationInSeconds,
        quorum,
        numEligibleVoters
    ) {}

    function _execute() internal returns (uint16 error) {
        return MPB_RETURN;
    }

}