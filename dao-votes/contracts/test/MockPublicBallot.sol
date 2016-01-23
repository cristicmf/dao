import "../src/PublicBallot.sol";

contract MockPublicBallot is PublicBallot {

    function MockPublicBallot(
        uint id,
        address userDatabase,
        address creator,
        uint durationInSeconds,
        uint8 quorum,
        uint numEligibleVoters
    ) PublicBallot(
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