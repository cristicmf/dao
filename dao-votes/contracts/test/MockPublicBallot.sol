import "../src/AbstractPublicBallot.sol";

contract MockPublicBallot is AbstractPublicBallot {

    function MockPublicBallot(
        uint id,
        address userDatabase,
        address creator,
        uint durationInSeconds,
        uint8 quorum,
        uint numEligibleVoters
    ) AbstractPublicBallot(
        id,
        userDatabase,
        creator,
        durationInSeconds,
        quorum,
        numEligibleVoters
    ) {}

    function _execute() internal returns (uint16 error) {
        return 0;
    }

}