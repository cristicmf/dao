import "./PublicCurrencyBase.sol";
import "../src/currency/PublicCurrency.sol";
import "../src/currency/PublicDurationBallot.sol";
import "../../../dao-users/contracts/test/MockUserDatabase.sol";
import "../../../dao-currency/contracts/test/MockCurrencyDatabase.sol";

contract PublicCurrencyDurationTest is PublicCurrencyBase {

    function testCreateDurationBallotSuccess() {
        var mdb = new MockUserDatabase(block.timestamp, true, TEST_NUM_ELIGIBLE_VOTERS);
        var pc = new PublicCurrency(TEST_ADDRESS, mdb);
        pc.createDurationBallot(1).assertNoError("createDurationBallot returned error");

        var (addr,) = pc.ballotFromIndex(0);
        var pmb = PublicDurationBallot(addr);
        
        // Check that all the fields in the vote is ok.
        pmb.id().assertEqual(TEST_ID, "id returns the wrong value.");
        pmb.userDatabase().assertEqual(mdb, "userDatabase returns the wrong value.");
        pmb.durationInSeconds().assertEqual(TEST_DURATION, "durationInSeconds returns the wrong value.");
        pmb.numEligibleVoters().assertEqual(TEST_NUM_ELIGIBLE_VOTERS, "numEligibleVoters returns the wrong value.");

        uint state = pmb.state();
        state.assertEqual(1, "state returns the wrong value.");
        uint quorum = pmb.quorum();
        quorum.assertEqual(TEST_QUORUM, "quorum returns the wrong value.");
        pmb.newDuration().assertEqual(1, "amount returned wrong number");
    }

    function testCreateDurationBallotFailDurationIsTheSame() {
        var mdb = new MockUserDatabase(block.timestamp, true, TEST_NUM_ELIGIBLE_VOTERS);
        var pc = new PublicCurrency(TEST_ADDRESS, mdb);
        pc.createDurationBallot(TEST_DURATION).assertErrorsEqual(INVALID_PARAM_VALUE, "createDurationBallot returned the wrong error");

        var (, exists) = pc.ballotFromIndex(0);
        exists.assertFalse("ballotFromIndex returned the wrong existence value");
    }

    function testCreateDurationBallotFailNotUser() {
        var mdb = new MockUserDatabase(0, false, 0);
        var pc = new PublicCurrency(TEST_ADDRESS, mdb);
        pc.createDurationBallot(1).assertErrorsEqual(RESOURCE_NOT_FOUND, "createDurationBallot returned the wrong error");

        var (, exists) = pc.ballotFromIndex(0);
        exists.assertFalse("ballotFromIndex returned the wrong existence value");
    }

    function testSetDurationFailCallerNotBallot() {
        var mdb = new MockUserDatabase(0, false, 0);
        var pc = new PublicCurrency(TEST_ADDRESS, TEST_ADDRESS_2);
        pc.setDuration(TEST_DURATION).assertErrorsEqual(ACCESS_DENIED, "setDuration returned no 'access denied' error");
    }

    function testDurationBallotSuccessVotePassed() {
        var mdb = new MockUserDatabase(block.timestamp, true, TEST_NUM_ELIGIBLE_VOTERS);
        var mcd = new MockCurrencyDatabase();
        var pc = new PublicCurrency(mcd, mdb);
        pc.createDurationBallot(1).assertNoError("createDurationBallot returned error");

        var (addr,) = pc.ballotFromIndex(0);
        var pmb = PublicDurationBallot(addr);
        pc.vote(pmb, 1).assertNoError("Vote returned an error.");

        uint state = pmb.state();
        state.assertEqual(2, "state returned the wrong value");
        pmb.result().assertEqual(1, "vote result wrong");
        pmb.execError().assertErrorsEqual(NO_ERROR, "execError returned the wrong error");

        pc.duration().assertEqual(1, "duration returns the wrong value");
    }

    function testDurationBallotSuccessVoteDidNotPass() {
        var mdb = new MockUserDatabase(block.timestamp, true, TEST_NUM_ELIGIBLE_VOTERS);
        var mcd = new MockCurrencyDatabase();
        var pc = new PublicCurrency(mcd, mdb);
        pc.createDurationBallot(1).assertNoError("createDurationBallot returned error");

        var (addr,) = pc.ballotFromIndex(0);
        var pmb = PublicDurationBallot(addr);
        pc.vote(pmb, 3).assertNoError("vote returned an error");

        uint state = pmb.state();
        state.assertEqual(2, "state returned the wrong value.");
        pmb.result().assertEqual(0, "vote result wrong");
        pmb.execError().assertErrorsEqual(NO_ERROR, "execError returned the wrong error");

        pc.duration().assertEqual(TEST_DURATION, "duration returns the wrong value");
    }

}