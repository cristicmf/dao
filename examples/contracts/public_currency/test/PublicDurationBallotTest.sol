import "./MockPublicCurrency.sol";
import "public-currency/src/PublicDurationBallot.sol";
import "dao-users/test/MockUserDatabase.sol";
import "dao-stl/src/assertions/DaoTest.sol";

contract PublicDurationBallotTest is DaoTest {

    uint    constant TEST_ID                    = 1;
    uint    constant TEST_ID_2                  = 2;
    uint    constant TEST_DURATION              = 1 days;
    uint8   constant TEST_QUORUM                = 0;
    uint    constant TEST_NUM_ELIGIBLE_VOTERS   = 1;
    uint16  constant MPC_RETURN                 = 0x333;
    address constant TEST_ADDRESS               = 0x12345;

    function testCreate() {
        var mdb = new MockUserDatabase(0, true, 0);
        var mpc = new MockPublicCurrency();
        var pdb = PublicDurationBallot(mpc.createDurationBallot(TEST_ID, mdb, this, block.timestamp,
            TEST_DURATION, TEST_QUORUM, TEST_NUM_ELIGIBLE_VOTERS, 1));

        pdb.newDuration().assertEqual(1, "newDuration is wrong");
    }

    function testExecute() {
        var mdb = new MockUserDatabase(block.timestamp, true, 0);
        var mpc = new MockPublicCurrency();
        var pdb = PublicDurationBallot(mpc.createDurationBallot(TEST_ID, mdb, this, block.timestamp,
            TEST_DURATION, TEST_QUORUM, TEST_NUM_ELIGIBLE_VOTERS, 1));
        mpc.vote(this, 1, block.timestamp);

        mpc.duration().assertEqual(1, "getData is wrong");
    }

}