import "../src/BallotMap.sol";

import "../../../dao-stl/contracts/src/assertions/Asserter.sol";

contract BallotMapImpl is BallotMap {

    function insert(address key, uint8 value) returns (bool added) {
        return _insert(key, value);
    }

    function remove(address key) returns (uint8 value, bool removed) {
        return _remove(key);
    }
}


contract BallotMapTest is Asserter {

    address constant TEST_KEY   = 0x12345;
    address constant TEST_KEY_2 = 0xABCDEF;
    address constant TEST_KEY_3 = 0xC0FFEE;

    uint8 constant TEST_VALUE   = 1;
    uint8 constant TEST_VALUE_2 = 2;
    uint8 constant TEST_VALUE_3 = 3;

    function testInsert() {
        BallotMapImpl bmi = new BallotMapImpl();
        bmi.insert(TEST_KEY, TEST_VALUE);
        assertUintsEqual(bmi.ballot(TEST_KEY), TEST_VALUE, "ballot returns the wrong value");
        var (addr, value, exists) = bmi.ballotFromIndex(0);
        assertTrue(exists, "ballotFromIndex exist is false");
        assertAddressesEqual(addr, TEST_KEY, "ballotFromIndex returns the wrong address");
        assertUintsEqual(bmi.numBallots(), 1, "numBallots is not 1");
    }

    function testRemove() {
        BallotMapImpl bmi = new BallotMapImpl();
        bmi.insert(TEST_KEY, TEST_VALUE);
        var (val, removed) = bmi.remove(TEST_KEY);
        assertUintsEqual(val, TEST_VALUE, "remove returns the wrong address");
        assertTrue(removed, "remove returns the wrong result");

        assertUintZero(bmi.ballot(TEST_KEY), "ballot returns the wrong value");
        var (addr, value, exists) = bmi.ballotFromIndex(0);
        assertAddressZero(addr, "ballotFromIndex returns the wrong key");
        assertFalse(exists, "ballotFromIndex returns the wrong existence value");
        assertUintZero(bmi.numBallots(), "numBallots is not 0");
    }

    function testAddTwo() {
        BallotMapImpl bmi = new BallotMapImpl();
        bmi.insert(TEST_KEY, TEST_VALUE);
        bmi.insert(TEST_KEY_2, TEST_VALUE_2);

        assertUintsEqual(bmi.ballot(TEST_KEY), TEST_VALUE, "ballot returns the wrong value for the first entry");
        assertUintsEqual(bmi.ballot(TEST_KEY_2), TEST_VALUE_2, "ballot returns the wrong value for the second entry");

        var (addr, value, exists) = bmi.ballotFromIndex(0);
        assertTrue(exists, "ballotFromIndex exist is false for first entry.");
        assertAddressesEqual(addr, TEST_KEY, "ballotFromIndex returns the wrong key for the first entry.");

        (addr, value, exists) = bmi.ballotFromIndex(1);
        assertTrue(exists, "ballotFromIndex exist is false for second entry.");
        assertAddressesEqual(addr, TEST_KEY_2, "ballotFromIndex returns the wrong key for second entry.");

        assertUintsEqual(bmi.numBallots(), 2, "numBallots is not 2");
    }

    function testAddTwoRemoveLast() {
        BallotMapImpl bmi = new BallotMapImpl();
        bmi.insert(TEST_KEY, TEST_VALUE);
        bmi.insert(TEST_KEY_2, TEST_VALUE_2);
        bmi.remove(TEST_KEY_2);

        assertUintsEqual(bmi.ballot(TEST_KEY), TEST_VALUE, "ballot returns the wrong value for the first entry");
        assertUintZero(bmi.ballot(TEST_KEY_2), "ballot returns the wrong value for the second entry");

        var (addr, value, exists) = bmi.ballotFromIndex(0);
        assertTrue(exists, "ballotFromIndex exist is false for first entry.");
        assertAddressesEqual(addr, TEST_KEY, "ballotFromIndex returns the wrong key for the first entry.");
        (addr, value, exists) = bmi.ballotFromIndex(1);
        assertFalse(exists, "ballotFromIndex exist is false for second entry.");
        assertAddressZero(addr, "ballotFromIndex returns the wrong key for second entry.");

        assertUintsEqual(bmi.numBallots(), 1, "numBallots is not 1");
    }

    function testAddTwoRemoveFirst() {
        BallotMapImpl bmi = new BallotMapImpl();
        bmi.insert(TEST_KEY, TEST_VALUE);
        bmi.insert(TEST_KEY_2, TEST_VALUE_2);
        bmi.remove(TEST_KEY);

        assertUintZero(bmi.ballot(TEST_KEY), "ballot returns the wrong value for the first entry");
        assertUintsEqual(bmi.ballot(TEST_KEY_2), TEST_VALUE_2, "ballot returns the wrong value for the second entry");

        var (addr, value, exists) = bmi.ballotFromIndex(0);
        assertTrue(exists, "ballotFromIndex exist is false for first entry.");
        assertAddressesEqual(addr, TEST_KEY_2, "ballotFromIndex returns the wrong key for the first entry.");
        (addr, value, exists) = bmi.ballotFromIndex(1);
        assertFalse(exists, "ballotFromIndex exist is false for second entry.");
        assertAddressZero(addr, "ballotFromIndex returns the wrong key for second entry.");

        assertUintsEqual(bmi.numBallots(), 1, "numBallots is not 1");
    }

    function testAddThreeRemoveMiddle() {

        BallotMapImpl bmi = new BallotMapImpl();
        bmi.insert(TEST_KEY, TEST_VALUE);
        bmi.insert(TEST_KEY_2, TEST_VALUE_2);
        bmi.insert(TEST_KEY_3, TEST_VALUE_3);
        bmi.remove(TEST_KEY_2);

        assertUintsEqual(bmi.ballot(TEST_KEY), TEST_VALUE, "ballot returns the wrong value for the first entry");
        assertUintZero(bmi.ballot(TEST_KEY_2), "ballot returns the wrong value for the second entry");
        assertUintsEqual(bmi.ballot(TEST_KEY_3), TEST_VALUE_3, "ballot returns the wrong value for the third entry");

        var (addr, value, exists) = bmi.ballotFromIndex(0);
        assertTrue(exists, "ballotFromIndex exist is false for first entry.");
        assertAddressesEqual(addr, TEST_KEY, "ballotFromIndex returns the wrong key for the first entry.");

        (addr, value, exists) = bmi.ballotFromIndex(1);
        assertTrue(exists, "ballotFromIndex exist is false for second entry.");
        assertAddressesEqual(addr, TEST_KEY_3, "ballotFromIndex returns the wrong key for the second entry.");

        (addr, value, exists) = bmi.ballotFromIndex(2);
        assertFalse(exists, "ballotFromIndex exist is false for third entry.");
        assertAddressZero(addr, "ballotFromIndex returns the wrong key for third entry.");

        assertUintsEqual(bmi.numBallots(), 2, "numBallots is not 2");
    }

}