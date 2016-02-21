import "./PublicCurrencyBase.sol";
import "public-currency/src/PublicCurrency.sol";
import "public-currency/src/PublicQuorumBallot.sol";
import "dao-users/test/MockUserDatabase.sol";
import "dao-currency/test/MockCurrencyDatabase.sol";

contract PublicCurrencyQuorumTest is PublicCurrencyBase {

    function testCreateQuorumBallotSuccess() {
        var mdb = new MockUserDatabase(block.timestamp, true, true, TEST_NUM_ELIGIBLE_VOTERS);
        var pc = new PublicCurrency(TEST_ADDRESS, mdb);
        pc.createQuorumBallot(1).assertNoError("createQuorumBallot returned error");

        var (addr,) = pc.ballotFromIndex(0);
        var pmb = PublicQuorumBallot(addr);
        
        // Check that all the fields in the vote is ok.
        pmb.id().assertEqual(TEST_ID, "id returns the wrong value.");
        pmb.userDatabase().assertEqual(mdb, "userDatabase returns the wrong value.");
        pmb.durationInSeconds().assertEqual(TEST_DURATION, "durationInSeconds returns the wrong value.");
        pmb.numEligibleVoters().assertEqual(TEST_NUM_ELIGIBLE_VOTERS, "numEligibleVoters returns the wrong value.");

        uint state = pmb.state();
        state.assertEqual(1, "state returns the wrong value.");
        uint quorum = pmb.quorum();
        quorum.assertEqual(TEST_QUORUM, "quorum returns the wrong value.");
        uint newQuorum = pmb.newQuorum();
        newQuorum.assertEqual(1, "amount returned wrong number");
    }

    function testCreateQuorumBallotFailQuorumIsTheSame() {
        var mdb = new MockUserDatabase(block.timestamp, true, true, TEST_NUM_ELIGIBLE_VOTERS);
        var pc = new PublicCurrency(TEST_ADDRESS, mdb);
        pc.createQuorumBallot(TEST_QUORUM).assertErrorsEqual(INVALID_PARAM_VALUE, "createQuorumBallot returned the wrong error");

        var (, exists) = pc.ballotFromIndex(0);
        exists.assertFalse("ballotFromIndex returned the wrong existence value");
    }

    function testCreateQuorumBallotFailNotUser() {
        var mdb = new MockUserDatabase(0, false, true, 0);
        var pc = new PublicCurrency(TEST_ADDRESS, mdb);
        pc.createQuorumBallot(1).assertErrorsEqual(RESOURCE_NOT_FOUND, "createQuorumBallot returned the wrong error");

        var (, exists) = pc.ballotFromIndex(0);
        exists.assertFalse("ballotFromIndex returned the wrong existence value");
    }

    function testSetQuorumFailCallerNotBallot() {
        var mdb = new MockUserDatabase(0, false, true, 0);
        var pc = new PublicCurrency(TEST_ADDRESS, TEST_ADDRESS_2);
        pc.setQuorum(TEST_QUORUM).assertErrorsEqual(ACCESS_DENIED, "setQuorum returned no 'access denied' error");
    }

    function testQuorumBallotSuccessVotePassed() {
        var mdb = new MockUserDatabase(block.timestamp, true, true, TEST_NUM_ELIGIBLE_VOTERS);
        var mcd = new MockCurrencyDatabase();
        var pc = new PublicCurrency(mcd, mdb);
        pc.createQuorumBallot(1).assertNoError("createQuorumBallot returned error");

        var (addr,) = pc.ballotFromIndex(0);
        var pmb = PublicQuorumBallot(addr);
        pc.vote(pmb, 1).assertNoError("Vote returned an error.");

        uint state = pmb.state();
        state.assertEqual(2, "state returned the wrong value");
        pmb.result().assertEqual(1, "vote result wrong");
        pmb.execError().assertErrorsEqual(NO_ERROR, "execError returned the wrong error");
        uint quorum = pc.quorum();
        quorum.assertEqual(1, "duration returns the wrong value");
    }

    function testQuorumBallotSuccessVoteDidNotPass() {
        var mdb = new MockUserDatabase(block.timestamp, true, true, TEST_NUM_ELIGIBLE_VOTERS);
        var mcd = new MockCurrencyDatabase();
        var pc = new PublicCurrency(mcd, mdb);
        pc.createQuorumBallot(1).assertNoError("createQuorumBallot returned error");

        var (addr,) = pc.ballotFromIndex(0);
        var pmb = PublicQuorumBallot(addr);
        pc.vote(pmb, 3).assertNoError("vote returned an error");

        uint state = pmb.state();
        state.assertEqual(2, "state returned the wrong value.");
        pmb.result().assertEqual(0, "vote result wrong");
        pmb.execError().assertErrorsEqual(NO_ERROR, "execError returned the wrong error");
        uint quorum = pc.quorum();
        quorum.assertEqual(TEST_QUORUM, "duration returns the wrong value");
    }

}