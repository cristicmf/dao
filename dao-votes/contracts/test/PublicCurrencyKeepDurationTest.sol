import "./PublicCurrencyBase.sol";
import "../src/currency/PublicCurrency.sol";
import "../src/currency/PublicKeepDurationBallot.sol";
import "../../../dao-users/contracts/test/MockUserDatabase.sol";
import "../../../dao-currency/contracts/test/MockCurrencyDatabase.sol";

contract PublicCurrencyKeepDurationTest is PublicCurrencyBase {

    function testCreateKeepDurationBallotSuccess() {
        var mdb = new MockUserDatabase(block.timestamp, true, TEST_NUM_ELIGIBLE_VOTERS);
        var pc = new PublicCurrency(TEST_ADDRESS, mdb);
        pc.createKeepDurationBallot(1).assertNoError("createKeepDurationBallot returned error");

        var (addr,) = pc.ballotFromIndex(0);
        var pmb = PublicKeepDurationBallot(addr);
        
        // Check that all the fields in the vote is ok.
        pmb.id().assertEqual(TEST_ID, "id returns the wrong value.");
        pmb.userDatabase().assertEqual(mdb, "userDatabase returns the wrong value.");
        pmb.durationInSeconds().assertEqual(TEST_DURATION, "durationInSeconds returns the wrong value.");
        pmb.numEligibleVoters().assertEqual(TEST_NUM_ELIGIBLE_VOTERS, "numEligibleVoters returns the wrong value.");

        uint state = pmb.state();
        state.assertEqual(1, "state returns the wrong value.");
        uint quorum = pmb.quorum();
        quorum.assertEqual(TEST_QUORUM, "quorum returns the wrong value.");
        pmb.keepDuration().assertEqual(1, "keep duration returned wrong number");
    }

    function testCreateKeepDurationBallotFailDurationIsTheSame() {
        var mdb = new MockUserDatabase(block.timestamp, true, TEST_NUM_ELIGIBLE_VOTERS);
        var pc = new PublicCurrency(TEST_ADDRESS, mdb);
        pc.createKeepDurationBallot(TEST_KEEP_DURATION).assertErrorsEqual(INVALID_PARAM_VALUE, "createKeepDurationBallot returned the wrong error");

        var (, exists) = pc.ballotFromIndex(0);
        exists.assertFalse("ballotFromIndex returned the wrong existence value");
    }

    function testCreateKeepDurationBallotFailNotUser() {
        var mdb = new MockUserDatabase(0, false, 0);
        var pc = new PublicCurrency(TEST_ADDRESS, mdb);
        pc.createKeepDurationBallot(1).assertErrorsEqual(RESOURCE_NOT_FOUND, "createKeepDurationBallot returned the wrong error");

        var (, exists) = pc.ballotFromIndex(0);
        exists.assertFalse("ballotFromIndex returned the wrong existence value");
    }

    function testSetKeepDurationFailCallerNotBallot() {
        var mdb = new MockUserDatabase(0, false, 0);
        var pc = new PublicCurrency(TEST_ADDRESS, TEST_ADDRESS_2);
        pc.setKeepDuration(TEST_DURATION).assertErrorsEqual(ACCESS_DENIED, "setKeepDuration returned no 'access denied' error");
    }

    function testKeepDurationBallotSuccessVotePassed() {
        var mdb = new MockUserDatabase(block.timestamp, true, TEST_NUM_ELIGIBLE_VOTERS);
        var mcd = new MockCurrencyDatabase();
        var pc = new PublicCurrency(mcd, mdb);
        pc.createKeepDurationBallot(1).assertNoError("createKeepDurationBallot returned error");

        var (addr,) = pc.ballotFromIndex(0);
        var pmb = PublicKeepDurationBallot(addr);
        pc.vote(pmb, 1).assertNoError("Vote returned an error.");

        uint state = pmb.state();
        state.assertEqual(2, "state returned the wrong value");
        pmb.result().assertEqual(1, "vote result wrong");
        pmb.execError().assertErrorsEqual(NO_ERROR, "execError returned the wrong error");

        pc.keepDuration().assertEqual(1, "keep-duration returns the wrong value");
    }

    function testKeepDurationBallotSuccessVoteDidNotPass() {
        var mdb = new MockUserDatabase(block.timestamp, true, TEST_NUM_ELIGIBLE_VOTERS);
        var mcd = new MockCurrencyDatabase();
        var pc = new PublicCurrency(mcd, mdb);
        pc.createKeepDurationBallot(1).assertNoError("createKeepDurationBallot returned error");

        var (addr,) = pc.ballotFromIndex(0);
        var pmb = PublicKeepDurationBallot(addr);
        pc.vote(pmb, 3).assertNoError("vote returned an error");

        uint state = pmb.state();
        state.assertEqual(2, "state returned the wrong value.");
        pmb.result().assertEqual(0, "vote result wrong");
        pmb.execError().assertErrorsEqual(NO_ERROR, "execError returned the wrong error");

        pc.keepDuration().assertEqual(TEST_KEEP_DURATION, "keep-duration returns the wrong value");
    }

}