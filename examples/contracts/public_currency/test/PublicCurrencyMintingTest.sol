import "./PublicCurrencyBase.sol";
import "public-currency/src/PublicCurrency.sol";
import "public-currency/src/PublicMintingBallot.sol";
import "dao-users/test/MockUserDatabase.sol";
import "dao-currency/test/MockCurrencyDatabase.sol";

contract PublicCurrencyMintingTest is PublicCurrencyBase {

    function testCreateMintBallotSuccess() {
        var mdb = new MockUserDatabase(block.timestamp, true, true, TEST_NUM_ELIGIBLE_VOTERS);
        var pc = new PublicCurrency(TEST_ADDRESS, mdb);
        pc.createMintBallot(this, 1).assertNoError("createMintBallot returned error");

        var (addr,) = pc.ballotFromIndex(0);
        var pmb = PublicMintingBallot(addr);
        
        // Check that all the fields in the vote is ok.
        pmb.id().assertEqual(TEST_ID, "id returns the wrong value.");
        pmb.userDatabase().assertEqual(mdb, "userDatabase returns the wrong value.");
        pmb.durationInSeconds().assertEqual(TEST_DURATION, "durationInSeconds returns the wrong value.");
        pmb.numEligibleVoters().assertEqual(TEST_NUM_ELIGIBLE_VOTERS, "numEligibleVoters returns the wrong value.");

        uint state = pmb.state();
        state.assertEqual(1, "state returns the wrong value.");
        uint quorum = pmb.quorum();
        quorum.assertEqual(TEST_QUORUM, "quorum returns the wrong value.");
        pmb.receiver().assertEqual(this, "receiver returned wrong address");
        pmb.amount().assertEqual(1, "amount returned wrong number");
    }

    function testCreateMintBallotFailReceiverIsNull() {
        var mdb = new MockUserDatabase(block.timestamp, true, true, TEST_NUM_ELIGIBLE_VOTERS);
        var pc = new PublicCurrency(TEST_ADDRESS, mdb);
        pc.createMintBallot(0, 1).assertErrorsEqual(NULL_PARAM_NOT_ALLOWED, "createMintBallot returned the wrong error");

        var (, exists) = pc.ballotFromIndex(0);
        exists.assertFalse("ballotFromIndex returned the wrong existence value");
    }

    function testCreateMintBallotFailAmountIsNull() {
        var mdb = new MockUserDatabase(block.timestamp, true, true, TEST_NUM_ELIGIBLE_VOTERS);
        var pc = new PublicCurrency(TEST_ADDRESS, mdb);
        pc.createMintBallot(this, 0).assertErrorsEqual(NULL_PARAM_NOT_ALLOWED, "createMintBallot returned the wrong error");

        var (, exists) = pc.ballotFromIndex(0);
        exists.assertFalse("ballotFromIndex returned the wrong existence value");
    }

    function testCreateMintBallotFailNotUser() {
        var mdb = new MockUserDatabase(0, false, true, 0);
        var pc = new PublicCurrency(TEST_ADDRESS, mdb);
        pc.createMintBallot(this, 1).assertErrorsEqual(RESOURCE_NOT_FOUND, "createMintBallot returned the wrong error");

        var (, exists) = pc.ballotFromIndex(0);
        exists.assertFalse("ballotFromIndex returned the wrong existence value");
    }

    function testMintingFailCallerNotBallot() {
        var mdb = new MockUserDatabase(0, false, true, 0);
        var pc = new PublicCurrency(TEST_ADDRESS, TEST_ADDRESS_2);
        pc.mint(this, 1).assertErrorsEqual(ACCESS_DENIED, "mint returned no 'access denied' error");
    }

    function testMintBallotSuccessVotePassed() {
        var mdb = new MockUserDatabase(block.timestamp, true, true, TEST_NUM_ELIGIBLE_VOTERS);
        var mcd = new MockCurrencyDatabase();
        var pc = new PublicCurrency(mcd, mdb);
        pc.createMintBallot(this, 1).assertNoError("createMintBallot returned error");

        var (addr,) = pc.ballotFromIndex(0);
        var pmb = PublicMintingBallot(addr);
        pc.vote(pmb, 1).assertNoError("Vote returned an error.");

        uint state = pmb.state();
        state.assertEqual(2, "state returned the wrong value.");
        pmb.result().assertEqual(1, "vote result wrong");
        pmb.execError().assertErrorsEqual(MCD_RETURN, "execError returned the wrong error");

        // Check what's in the currency database.
        var (mAddr, mAmt) = mcd.addData();
        mAddr.assertEqual(this, "Currency database returns wrong receiver");
        mAmt.assertEqual(1, "Currency database returns wrong amount");
    }

    function testMintBallotSuccessVoteDidNotPass() {
        var mdb = new MockUserDatabase(block.timestamp, true, true, TEST_NUM_ELIGIBLE_VOTERS);
        var mcd = new MockCurrencyDatabase();
        var pc = new PublicCurrency(mcd, mdb);
        pc.createMintBallot(this, 1).assertNoError("createMintBallot returned error");

        var (addr,) = pc.ballotFromIndex(0);
        var pmb = PublicMintingBallot(addr);
        pc.vote(pmb, 3).assertNoError("Vote returned an error.");

        uint state = pmb.state();
        state.assertEqual(2, "state returned the wrong value.");
        pmb.result().assertEqual(0, "vote result wrong");
        pmb.execError().assertErrorsEqual(NO_ERROR, "execError returned the wrong error");

        // Check what's in the currency database.
        var (mAddr, mAmt) = mcd.addData();
        mAddr.assertZero("Currency database returns wrong receiver");
        mAmt.assertZero("Currency database returns wrong amount");
    }

}