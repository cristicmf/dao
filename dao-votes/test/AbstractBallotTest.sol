import "./MockBallot.sol";
import "dao-stl/src/assertions/DaoTest.sol";

contract AbstractBallotTest is DaoTest {

    uint constant TEST_ID = 1;
    uint constant TEST_DURATION = 1 days;

    uint16 constant MB_RETURN = 0x2121;

    address constant TEST_ADDRESS = 0x12345;

    function testCreate() {
        var mb = new MockBallot(TEST_ID, this, block.timestamp, TEST_DURATION);

        mb.id().assertEqual(TEST_ID, "id is wrong.");
        mb.creator().assertEqual(this, "creator is wrong");
        mb.opened().assertEqual(block.timestamp, "opened is false");
        mb.durationInSeconds().assertEqual(TEST_DURATION, "durationInSeconds returns the wrong value.");
        // Cleaner when having to do conversions.
        uint state = mb.state();
        state.assertEqual(1, "state returns the wrong value.");
        mb.concluded().assertZero("concluded is wrong");
    }


}