import "./MockPublicBallot.sol";
import "dao-users/test/MockUserDatabase.sol";
import "dao-stl/src/assertions/DaoTest.sol";

contract PublicBallotTest is DaoTest {

    uint constant TEST_ID = 1;
    uint constant TEST_DURATION = 1 days;
    uint8 constant TEST_QUORUM = 50;
    uint constant TEST_NUM_ELIGIBLE_VOTERS = 2;

    uint16 constant MPB_RETURN = 0x2222;

    address constant TEST_ADDRESS = 0x12345;

    function testCreate() {
        var mdb = new MockUserDatabase(0, true, 0);
        var mpb = new MockPublicBallot(TEST_ID, mdb, this, block.timestamp, TEST_DURATION, TEST_QUORUM, TEST_NUM_ELIGIBLE_VOTERS);

        mpb.id().assertEqual(TEST_ID, "id returns the wrong value.");
        mpb.userDatabase().assertEqual(mdb, "userDatabase returns the wrong value.");
        mpb.durationInSeconds().assertEqual(TEST_DURATION, "durationInSeconds returns the wrong value.");
        mpb.numEligibleVoters().assertEqual(TEST_NUM_ELIGIBLE_VOTERS, "numEligibleVoters returns the wrong value.");
        // Cleaner when having to do conversions.
        uint state = mpb.state();
        state.assertEqual(1, "state returns the wrong value.");
        uint quorum = mpb.quorum();
        quorum.assertEqual(TEST_QUORUM, "quorum returns the wrong value.");
    }

    function testYesVoteSuccess() {
        var mdb = new MockUserDatabase(block.timestamp, true, 0);
        var mpb = new MockPublicBallot(TEST_ID, mdb, this, block.timestamp, TEST_DURATION, TEST_QUORUM, TEST_NUM_ELIGIBLE_VOTERS);
        mpb.vote(this, 1, block.timestamp).assertNoError("vote returned error");

        var (vote, err) = mpb.voterData(this);
        uint(vote).assertEqual(1, "voterData returned the wrong vote");
        err.assertNoError("voterData returned an error");
        address addr;
        (addr, vote, err) = mpb.voterDataFromIndex(0);
        addr.assertEqual(this, "voterDataFromIndex returned the wrong address");
        uint(vote).assertEqual(1, "voterDataFromIndex returned the wrong vote");
        err.assertNoError("voterDataFromIndex returned an error");

        mpb.result().assertEqual(1, "result returned the wrong value");
        mpb.numVotes().assertEqual(1, "numVotes returned the wrong number of votes");
        uint state = mpb.state();
        state.assertEqual(1, "state returns the wrong value.");
    }

    function testNoVoteSuccess() {
        var mdb = new MockUserDatabase(block.timestamp, true, 0);
        var mpb = new MockPublicBallot(TEST_ID, mdb, this, block.timestamp, TEST_DURATION, TEST_QUORUM, TEST_NUM_ELIGIBLE_VOTERS);
        mpb.vote(this, 2, block.timestamp).assertNoError("vote returned error");

        mpb.result().assertEqual(-1, "result returned the wrong value");
    }

    function testAbstainVoteSuccess() {
        var mdb = new MockUserDatabase(block.timestamp, true, 0);
        var mpb = new MockPublicBallot(TEST_ID, mdb, this, block.timestamp, TEST_DURATION, TEST_QUORUM, TEST_NUM_ELIGIBLE_VOTERS);
        mpb.vote(this, 3, block.timestamp).assertNoError("vote returned error");

        mpb.result().assertEqual(0, "result returned the wrong value");
    }

    function testVoteFailedBadVoteValue() {
        var mdb = new MockUserDatabase(block.timestamp, true, 0);
        var mpb = new MockPublicBallot(TEST_ID, mdb, this, block.timestamp, TEST_DURATION, TEST_QUORUM, TEST_NUM_ELIGIBLE_VOTERS);
        mpb.vote(this, 0, block.timestamp).assertErrorsEqual(INVALID_PARAM_VALUE, "vote returned no 'invalid param' error");
        var (, err) = mpb.voterData(this);
        err.assertErrorsEqual(RESOURCE_NOT_FOUND, "voterData returns the wrong error");
        mpb.result().assertEqual(0, "result returned the wrong value");
    }

    function testVoteFailedTimeExpired() {
        var mdb = new MockUserDatabase(block.timestamp, true, 0);
        var mpb = new MockPublicBallot(TEST_ID, mdb, this, block.timestamp - 2 days, TEST_DURATION, TEST_QUORUM, TEST_NUM_ELIGIBLE_VOTERS);
        mpb.vote(this, 1, block.timestamp).assertErrorsEqual(INVALID_STATE, "vote returned no 'state' error");
        var (, err) = mpb.voterData(this);
        err.assertErrorsEqual(RESOURCE_NOT_FOUND, "voterData returns the wrong error");
        mpb.result().assertEqual(0, "result returned the wrong value");
    }

    function testVoteFailedAlreadyVoted() {
        var mdb = new MockUserDatabase(block.timestamp, true, 0);
        var mpb = new MockPublicBallot(TEST_ID, mdb, this, block.timestamp, TEST_DURATION, TEST_QUORUM, TEST_NUM_ELIGIBLE_VOTERS);
        mpb.vote(this, 1, block.timestamp);
        mpb.vote(this, 2, block.timestamp).assertErrorsEqual(RESOURCE_ALREADY_EXISTS, "vote returned no 'resource already exists' error");
        var (vote, ) = mpb.voterData(this);
        uint(vote).assertEqual(1, "voterData returns the wrong vote");
        mpb.result().assertEqual(1, "result returned the wrong value");
    }

    function testVoteFailedNotAUser() {
        var mdb = new MockUserDatabase(0, false, 0);
        var mpb = new MockPublicBallot(TEST_ID, mdb, this, block.timestamp, TEST_DURATION, TEST_QUORUM, TEST_NUM_ELIGIBLE_VOTERS);
        mpb.vote(this, 1, block.timestamp).assertErrorsEqual(ACCESS_DENIED, "vote returned no 'access denied' error");
        var (, err) = mpb.voterData(this);
        err.assertErrorsEqual(RESOURCE_NOT_FOUND, "voterData returns the wrong error");
        mpb.result().assertEqual(0, "result returned the wrong value");
    }

    function testVoteFailedUserJoinedAfterVoteOpened() {
        var mdb = new MockUserDatabase(block.timestamp + 1 days, true, 0);
        var mpb = new MockPublicBallot(TEST_ID, mdb, this, block.timestamp, TEST_DURATION, TEST_QUORUM, TEST_NUM_ELIGIBLE_VOTERS);
        mpb.vote(this, 1, block.timestamp).assertErrorsEqual(ACCESS_DENIED, "vote returned no 'access denied' error");
        var (, err) = mpb.voterData(this);
        err.assertErrorsEqual(RESOURCE_NOT_FOUND, "voterData returns the wrong error");
        mpb.result().assertEqual(0, "result returned the wrong value");
    }

    function testAutoFinalizeVotePassed() {
        var mdb = new MockUserDatabase(block.timestamp, true, 0);
        var mpb = new MockPublicBallot(TEST_ID, mdb, this, block.timestamp, TEST_DURATION, TEST_QUORUM, TEST_NUM_ELIGIBLE_VOTERS);
        mpb.vote(this, 1, block.timestamp).assertNoError("vote returned error");
        mpb.vote(TEST_ADDRESS, 1, block.timestamp).assertNoError("vote returned error for proxy");

        mpb.result().assertEqual(2, "result returned the wrong value");
        mpb.numVotes().assertEqual(2, "numVotes returned the wrong number of votes");
        uint state = mpb.state();
        state.assertEqual(2, "state returns the wrong value.");
        mpb.execError().assertErrorsEqual(MPB_RETURN, "execError is wrong");
        mpb.concluded().assertEqual(block.timestamp, "concluded returned the wrong value");
    }

    function testAutoFinalizeVoteDidNotPass() {
        var mdb = new MockUserDatabase(block.timestamp, true, 0);
        var mpb = new MockPublicBallot(TEST_ID, mdb, this, block.timestamp, TEST_DURATION, TEST_QUORUM, TEST_NUM_ELIGIBLE_VOTERS);
        mpb.vote(this, 1, block.timestamp).assertNoError("vote returned error");
        mpb.vote(TEST_ADDRESS, 2, block.timestamp).assertNoError("vote returned error for proxy");

        mpb.result().assertEqual(0, "result returned the wrong value");
        mpb.numVotes().assertEqual(2, "numVotes returned the wrong number of votes");
        uint state = mpb.state();
        state.assertEqual(2, "state returns the wrong value.");
        mpb.execError().assertErrorsEqual(NO_ERROR, "execError is wrong");
        mpb.concluded().assertEqual(block.timestamp, "concluded returned the wrong value");
    }

    function testManualFinalizeSuccessPassed() {
        var mdb = new MockUserDatabase(block.timestamp - 3 days, true, 0);
        var mpb = new MockPublicBallot(TEST_ID, mdb, this, block.timestamp - 2 days, TEST_DURATION, TEST_QUORUM, TEST_NUM_ELIGIBLE_VOTERS);
        mpb.vote(this, 1, block.timestamp - 2 days).assertNoError("vote returned error");
        var (passed, error, execError) = mpb.finalize();
        passed.assertTrue("finalize return wrong passed value");
        error.assertNoError("finalize return wrong error value");
        execError.assertErrorsEqual(MPB_RETURN, "finalize return wrong execError value");
        mpb.result().assertEqual(1, "result returned the wrong value");
        mpb.numVotes().assertEqual(1, "numVotes returned the wrong number of votes");
        uint state = mpb.state();
        state.assertEqual(2, "state returns the wrong value.");
        mpb.execError().assertErrorsEqual(MPB_RETURN, "execError is wrong");
        mpb.concluded().assertEqual(block.timestamp, "concluded returned the wrong value");
    }

    function testManualFinalizeSuccessDidNotPass() {
        var mdb = new MockUserDatabase(block.timestamp - 3 days, true, 0);
        var mpb = new MockPublicBallot(TEST_ID, mdb, this, block.timestamp - 2 days, TEST_DURATION, TEST_QUORUM, TEST_NUM_ELIGIBLE_VOTERS);
        mpb.vote(this, 2, block.timestamp - 2 days).assertNoError("vote returned error");
        var (passed, error, execError) = mpb.finalize();
        passed.assertFalse("finalize return wrong passed value");
        error.assertNoError("finalize return wrong error value");
        execError.assertNoError("finalize return wrong execError value");
        mpb.result().assertEqual(-1, "result returned the wrong value");
        mpb.numVotes().assertEqual(1, "numVotes returned the wrong number of votes");
        uint state = mpb.state();
        state.assertEqual(2, "state returns the wrong value.");
        mpb.execError().assertNoError( "execError is wrong");
        mpb.concluded().assertEqual(block.timestamp, "concluded returned the wrong value");
    }

    function testManualFinalizeFailAlreadyClosed() {
        var mdb = new MockUserDatabase(block.timestamp, true, 0);
        var mpb = new MockPublicBallot(TEST_ID, mdb, this, block.timestamp, TEST_DURATION, TEST_QUORUM, TEST_NUM_ELIGIBLE_VOTERS);
        mpb.vote(this, 1, block.timestamp).assertNoError("vote returned error");
        mpb.vote(TEST_ADDRESS, 1, block.timestamp);
        var (passed, error, execError) = mpb.finalize();
        passed.assertFalse("finalize return wrong passed value");
        error.assertErrorsEqual(INVALID_STATE, "finalize return wrong error value");
        execError.assertNoError("finalize return wrong execError value");
    }

    function testManualFinalizeFailTimeNotUp() {
        var mdb = new MockUserDatabase(0, false, 0);
        var mpb = new MockPublicBallot(TEST_ID, mdb, this, block.timestamp, TEST_DURATION, TEST_QUORUM, TEST_NUM_ELIGIBLE_VOTERS);

        var (passed, error, execError) = mpb.finalize();
        passed.assertFalse("finalize return wrong passed value");
        error.assertErrorsEqual(INVALID_STATE, "finalize return wrong error value");
        execError.assertNoError("finalize return wrong execError value");
        mpb.concluded().assertEqual(0, "concluded returned the wrong value");
    }

    function testManualFinalizeFailQuorum() {
        var mdb = new MockUserDatabase(0, false, 0);
        var mpb = new MockPublicBallot(TEST_ID, mdb, this, block.timestamp - 2 days, TEST_DURATION, TEST_QUORUM, TEST_NUM_ELIGIBLE_VOTERS);

        var (passed, error, execError) = mpb.finalize();
        passed.assertFalse("finalize return wrong passed value");
        error.assertErrorsEqual(ERROR, "finalize return wrong error value");
        execError.assertNoError("finalize return wrong execError value");
        mpb.concluded().assertEqual(0, "concluded returned the wrong value");
    }


}