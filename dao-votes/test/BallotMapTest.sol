import "dao-votes/src/BallotMap.sol";

import "dao-stl/src/assertions/DaoTest.sol";

contract BallotMapImpl is BallotMap {

    function insert(address key, bytes32 value) returns (bool added) {
        return _insert(key, value);
    }

    function remove(address key) returns (bytes32 value, bool removed) {
        return _remove(key);
    }
}

contract BallotMapTest is DaoTest {

    address constant TEST_KEY   = 0x12345;
    address constant TEST_KEY_2 = 0xABCDEF;
    address constant TEST_KEY_3 = 0xC0FFEE;

    bytes32 constant TEST_VALUE   = 0x1;
    bytes32 constant TEST_VALUE_2 = 0x2;
    bytes32 constant TEST_VALUE_3 = 0x3;

    function testInsert() {
        BallotMapImpl bmi = new BallotMapImpl();
        bmi.insert(TEST_KEY, TEST_VALUE);
        bmi.ballot(TEST_KEY).assertEqual(TEST_VALUE, "ballot returns the wrong value");
        var (addr, value, exists) = bmi.ballotFromIndex(0);
        exists.assert("ballotFromIndex exist is false");
        addr.assertEqual(TEST_KEY, "ballotFromIndex returns the wrong address");
        bmi.numBallots().assertEqual(1, "numBallots is not 1");
    }

    function testRemove() {
        BallotMapImpl bmi = new BallotMapImpl();
        bmi.insert(TEST_KEY, TEST_VALUE);
        var (val, removed) = bmi.remove(TEST_KEY);
        val.assertEqual(TEST_VALUE, "remove returns the wrong address");
        removed.assert("remove returns the wrong result");

        bmi.ballot(TEST_KEY).assertZero("ballot returns the wrong value");
        var (addr, value, exists) = bmi.ballotFromIndex(0);
        addr.assertZero("ballotFromIndex returns the wrong key");
        exists.assertFalse("ballotFromIndex returns the wrong existence value");
        bmi.numBallots().assertZero("numBallots is not 0");
    }

    function testAddTwo() {
        BallotMapImpl bmi = new BallotMapImpl();
        bmi.insert(TEST_KEY, TEST_VALUE);
        bmi.insert(TEST_KEY_2, TEST_VALUE_2);

        bmi.ballot(TEST_KEY).assertEqual(TEST_VALUE, "ballot returns the wrong value for the first entry");
        bmi.ballot(TEST_KEY_2).assertEqual(TEST_VALUE_2, "ballot returns the wrong value for the second entry");

        var (addr, value, exists) = bmi.ballotFromIndex(0);
        exists.assert("ballotFromIndex exist is false for first entry.");
        addr.assertEqual(TEST_KEY, "ballotFromIndex returns the wrong key for the first entry.");

        (addr, value, exists) = bmi.ballotFromIndex(1);
        exists.assert("ballotFromIndex exist is false for second entry.");
        addr.assertEqual(TEST_KEY_2, "ballotFromIndex returns the wrong key for second entry.");

        bmi.numBallots().assertEqual(2, "numBallots is not 2");
    }

    function testAddTwoRemoveLast() {
        BallotMapImpl bmi = new BallotMapImpl();
        bmi.insert(TEST_KEY, TEST_VALUE);
        bmi.insert(TEST_KEY_2, TEST_VALUE_2);
        bmi.remove(TEST_KEY_2);

        bmi.ballot(TEST_KEY).assertEqual(TEST_VALUE, "ballot returns the wrong value for the first entry");
        bmi.ballot(TEST_KEY_2).assertZero("ballot returns the wrong value for the second entry");

        var (addr, value, exists) = bmi.ballotFromIndex(0);
        exists.assert("ballotFromIndex exist is false for first entry.");
        addr.assertEqual(TEST_KEY, "ballotFromIndex returns the wrong key for the first entry.");
        (addr, value, exists) = bmi.ballotFromIndex(1);
        exists.assertFalse("ballotFromIndex exist is false for second entry.");
        addr.assertZero("ballotFromIndex returns the wrong key for second entry.");

        bmi.numBallots().assertEqual(1, "numBallots is not 1");
    }

    function testAddTwoRemoveFirst() {
        BallotMapImpl bmi = new BallotMapImpl();
        bmi.insert(TEST_KEY, TEST_VALUE);
        bmi.insert(TEST_KEY_2, TEST_VALUE_2);
        bmi.remove(TEST_KEY);

        bmi.ballot(TEST_KEY).assertZero("ballot returns the wrong value for the first entry");
        bmi.ballot(TEST_KEY_2).assertEqual(TEST_VALUE_2, "ballot returns the wrong value for the second entry");

        var (addr, value, exists) = bmi.ballotFromIndex(0);
        exists.assert("ballotFromIndex exist is false for first entry.");
        addr.assertEqual(TEST_KEY_2, "ballotFromIndex returns the wrong key for the first entry.");
        (addr, value, exists) = bmi.ballotFromIndex(1);
        exists.assertFalse("ballotFromIndex exist is false for second entry.");
        addr.assertZero("ballotFromIndex returns the wrong key for second entry.");

        bmi.numBallots().assertEqual(1, "numBallots is not 1");
    }

    function testAddThreeRemoveMiddle() {

        BallotMapImpl bmi = new BallotMapImpl();
        bmi.insert(TEST_KEY, TEST_VALUE);
        bmi.insert(TEST_KEY_2, TEST_VALUE_2);
        bmi.insert(TEST_KEY_3, TEST_VALUE_3);
        bmi.remove(TEST_KEY_2);

        bmi.ballot(TEST_KEY).assertEqual(TEST_VALUE, "ballot returns the wrong value for the first entry");
        bmi.ballot(TEST_KEY_2).assertZero("ballot returns the wrong value for the second entry");
        bmi.ballot(TEST_KEY_3).assertEqual(TEST_VALUE_3, "ballot returns the wrong value for the third entry");

        var (addr, value, exists) = bmi.ballotFromIndex(0);
        exists.assert("ballotFromIndex exist is false for first entry.");
        addr.assertEqual(TEST_KEY, "ballotFromIndex returns the wrong key for the first entry.");

        (addr, value, exists) = bmi.ballotFromIndex(1);
        exists.assert("ballotFromIndex exist is false for second entry.");
        addr.assertEqual(TEST_KEY_3, "ballotFromIndex returns the wrong key for the second entry.");

        (addr, value, exists) = bmi.ballotFromIndex(2);
        exists.assertFalse("ballotFromIndex exist is false for third entry.");
        addr.assertZero("ballotFromIndex returns the wrong key for third entry.");

        bmi.numBallots().assertEqual(2, "numBallots is not 2");
    }

}