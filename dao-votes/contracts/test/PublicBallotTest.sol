import "./MockPublicBallot.sol";
import "../../../dao-users/contracts/test/MockUserDatabase.sol";
import "../../../dao-stl/contracts/src/errors/Errors.sol";
import "../../../dao-stl/contracts/src/assertions/DaoAsserter.sol";

contract PublicBallotTest is DaoAsserter {

    uint constant TEST_ID = 1;
    uint constant TEST_DURATION = 1 days;
    uint8 constant TEST_QUORUM = 50;
    uint8 constant TEST_NUM_ELIGIBLE_VOTERS = 2;

    function testCreate() {
        var mdb = new MockUserDatabase(0, true, 0);
        var mpb = new MockPublicBallot(TEST_ID, mdb, this, TEST_DURATION, TEST_QUORUM, TEST_NUM_ELIGIBLE_VOTERS);
        assertUintsEqual(mpb.id(), TEST_ID, "id returns the wrong value.");
        assertAddressesEqual(mpb.userDatabase(), mdb, "userDatabase returns the wrong value.");
        assertUintsEqual(mpb.durationInSeconds(), TEST_DURATION, "durationInSeconds returns the wrong value.");
        assertUintsEqual(mpb.numEligibleVoters(), TEST_NUM_ELIGIBLE_VOTERS, "numEligibleVoters returns the wrong value.");
        assertUintsEqual(mpb.state(), 1, "id returns the wrong value.");
        assertUintsEqual(mpb.quorum(), TEST_QUORUM, "quorum returns the wrong value.");
    }

}