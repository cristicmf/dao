import "./MockDatabaseDoug.sol";
import "../src/DefaultUserDatabase.sol";
import "../../../dao-stl/src/assertions/DaoAsserter.sol";

contract UserDatabaseTest is DaoAsserter {

    address constant TEST_ADDRESS = 0x12345;
    address constant TEST_ADDRESS_2 = 0xABCDEF;
    address constant TEST_ADDRESS_3 = 0xC0FFEE;

    bytes32 constant TEST_NICKNAME = 0x1;
    bytes32 constant TEST_NICKNAME_2 = 0x2;
    bytes32 constant TEST_NICKNAME_3 = 0x3;

    bytes32 constant TEST_HASH = 0x11;
    bytes32 constant TEST_HASH_2 = 0x22;
    bytes32 constant TEST_HASH_3 = 0x33;

    uint constant TEST_TIMESTAMP = 0x111;
    uint constant TEST_TIMESTAMP_2 = 0x222;

    function testInsert() {
        var mdd = new MockDatabaseDoug(true);
        var udb = new DefaultUserDatabase();
        udb.setDougAddress(address(mdd));
        
        udb.registerUser(TEST_ADDRESS, TEST_NICKNAME, TEST_TIMESTAMP, TEST_HASH);
        assertTrue(udb.hasUser(TEST_ADDRESS), "hasUser returned false");

        var (a, e) = udb.userAddressFromIndex(0);
        assertNoError(e, "userFromIndex returned an error");
        assertAddressesEqual(a, TEST_ADDRESS, "userFromIndex address is wrong");

        var (nn, ts, dh) = udb.user(TEST_ADDRESS);
        assertBytes32Equal(nn, TEST_NICKNAME, "user returning the wrong nickname");
        assertUintsEqual(ts, TEST_TIMESTAMP, "user returning the wrong timestamp");
        assertBytes32Equal(dh, TEST_HASH, "user returning the wrong data-hash");
        assertUintsEqual(udb.size(), 1, "size is not 1");
    }


    function testRegisterFailNotDoug() {
        var mdd = new MockDatabaseDoug(false);
        var udb = new DefaultUserDatabase();
        udb.setDougAddress(address(mdd));

        var err = udb.registerUser(TEST_ADDRESS, TEST_NICKNAME, TEST_TIMESTAMP, 0);
        assertErrorsEqual(err, ACCESS_DENIED, "registerUser did not return an 'access denied' error");

    }

    function testOverwriteFail() {
        var udb = new DefaultUserDatabase();
        udb.setDougAddress(address(this));

        udb.registerUser(TEST_ADDRESS, TEST_NICKNAME, TEST_TIMESTAMP, TEST_HASH);
        var aErr = udb.registerUser(TEST_ADDRESS, TEST_NICKNAME_2, TEST_TIMESTAMP_2, TEST_HASH_2);
        assertErrorsEqual(aErr, RESOURCE_ALREADY_EXISTS, "registerUser returned no error");
        var (nn, ts, dh) = udb.user(TEST_ADDRESS);
        assertBytes32Equal(nn, TEST_NICKNAME, "user returning the wrong nickname");
        assertUintsEqual(ts, TEST_TIMESTAMP, "user returning the wrong timestamp");
        assertBytes32Equal(dh, TEST_HASH, "user returning the wrong data-hash");
        assertUintsEqual(udb.size(), 1, "size is not 1");
    }

    function testRemove() {
        var mdd = new MockDatabaseDoug(true);
        var udb = new DefaultUserDatabase();
        udb.setDougAddress(address(mdd));

        udb.registerUser(TEST_ADDRESS, TEST_NICKNAME, TEST_TIMESTAMP, TEST_HASH);
        udb.removeUser(TEST_ADDRESS);
        assertFalse(udb.hasUser(TEST_ADDRESS), "hasUser returned true");
        var (a, e) = udb.userAddressFromIndex(0);
        assertErrorsEqual(e, ARRAY_INDEX_OUT_OF_BOUNDS, "userFromIndex returned no 'array index out-of-bounds' error");
        assertAddressZero(a, "userFromIndex address is not null");
        var (nn, ts, dh) = udb.user(TEST_ADDRESS);
        assertBytes32Zero(nn, "user returning the wrong nickname");
        assertUintZero(ts, "user returning the wrong timestamp");
        assertBytes32Zero(dh, "user returning the wrong data-hash");
        assertUintZero(udb.size(), "size is not 0");
    }

    function testRemoveFailNotDoug() {
        var mdd = new MockDatabaseDoug(false);
        var udb = new DefaultUserDatabase();
        udb.setDougAddress(address(mdd));

        var err = udb.removeUser(TEST_ADDRESS);
        assertErrorsEqual(err, ACCESS_DENIED, "registerUser did not return an 'access denied' error");
    }

    function testUpdateDataHash() {
        var mdd = new MockDatabaseDoug(true);
        var udb = new DefaultUserDatabase();
        udb.setDougAddress(address(mdd));

        udb.registerUser(TEST_ADDRESS, TEST_NICKNAME, TEST_TIMESTAMP, TEST_HASH);

        var err = udb.updateDataHash(TEST_ADDRESS, TEST_HASH_2);
        assertNoError(err, "updateDataHash returned an error");

        var (, dh) = udb.user(TEST_ADDRESS);
        assertBytes32Equal(dh, TEST_HASH_2, "user returning the wrong data-hash");
    }

    function testUpdateDataHashFailNotDoug() {
        var mdd = new MockDatabaseDoug(false);
        var udb = new DefaultUserDatabase();
        udb.setDougAddress(address(mdd));

        udb.registerUser(TEST_ADDRESS, TEST_NICKNAME, TEST_TIMESTAMP, TEST_HASH);

        var err = udb.updateDataHash(TEST_ADDRESS, TEST_HASH_2);
        assertErrorsEqual(err, ACCESS_DENIED, "updateDataHash did not return an 'access denied' error");
    }

    function testAddTwo() {

        var mdd = new MockDatabaseDoug(true);
        var udb = new DefaultUserDatabase();
        udb.setDougAddress(address(mdd));

        var aErr = udb.registerUser(TEST_ADDRESS, TEST_NICKNAME, TEST_TIMESTAMP, TEST_HASH);
        assertNoError(aErr, "Registering first user returned error");
        var aErr2 = udb.registerUser(TEST_ADDRESS_2, TEST_NICKNAME_2, TEST_TIMESTAMP_2, TEST_HASH_2);
        assertNoError(aErr2, "Registering second user returned error");

        assertTrue(udb.hasUser(TEST_ADDRESS), "hasUser returned false for first user");
        assertTrue(udb.hasUser(TEST_ADDRESS_2), "hasUser returned false for second user");

        var (a, e) = udb.userAddressFromIndex(0);
        assertNoError(e, "userFromIndex returned an error for first user");
        assertAddressesEqual(a, TEST_ADDRESS, "userFromIndex address is wrong for first user");

        (a, e) = udb.userAddressFromIndex(1);
        assertNoError(e, "userFromIndex returned an error for second user");
        assertAddressesEqual(a, TEST_ADDRESS_2, "userFromIndex address is wrong for second user");

        var (nn, ts, dh) = udb.user(TEST_ADDRESS);
        assertBytes32Equal(nn, TEST_NICKNAME, "first user returning the wrong nickname");
        assertUintsEqual(ts, TEST_TIMESTAMP, "first user returning the wrong timestamp");
        assertBytes32Equal(dh, TEST_HASH, "first user returning the wrong data-hash");

        (nn, ts, dh) = udb.user(TEST_ADDRESS_2);
        assertBytes32Equal(nn, TEST_NICKNAME_2, "second user returning the wrong nickname");
        assertUintsEqual(ts, TEST_TIMESTAMP_2, "second user returning the wrong timestamp");
        assertBytes32Equal(dh, TEST_HASH_2, "second user returning the wrong data-hash");

        assertUintsEqual(udb.size(), 2, "size is not 2");
    }

    function testAddTwoRemoveLast() {
        var mdd = new MockDatabaseDoug(true);
        var udb = new DefaultUserDatabase();
        udb.setDougAddress(address(mdd));

        udb.registerUser(TEST_ADDRESS, TEST_NICKNAME, TEST_TIMESTAMP, TEST_HASH);
        udb.registerUser(TEST_ADDRESS_2, TEST_NICKNAME_2, TEST_TIMESTAMP_2, TEST_HASH_2);
        udb.removeUser(TEST_ADDRESS_2);

        assertTrue(udb.hasUser(TEST_ADDRESS), "hasUser returned false for first user");
        assertFalse(udb.hasUser(TEST_ADDRESS_2), "hasUser returned true for second user");

        var (a, e) = udb.userAddressFromIndex(0);
        assertNoError(e, "userFromIndex returned an error for first user");
        assertAddressesEqual(a, TEST_ADDRESS, "userFromIndex address is wrong for first user");

        (a, e) = udb.userAddressFromIndex(1);
        assertErrorsEqual(e, ARRAY_INDEX_OUT_OF_BOUNDS, "userFromIndex did not return an 'array index out-of-bounds' for second user");
        assertAddressZero(a, "userFromIndex address is not zero for second user");

        var (nn, ts, dh) = udb.user(TEST_ADDRESS);
        assertBytes32Equal(nn, TEST_NICKNAME, "first user returning the wrong nickname");
        assertUintsEqual(ts, TEST_TIMESTAMP, "first user returning the wrong timestamp");
        assertBytes32Equal(dh, TEST_HASH, "first user returning the wrong data-hash");

        (nn, ts, dh) = udb.user(TEST_ADDRESS_2);
        assertBytes32Zero(nn, "second user returning the wrong nickname");
        assertUintZero(ts, "second user returning the wrong timestamp");
        assertBytes32Zero(dh, "second user returning the wrong data-hash");

        assertUintsEqual(udb.size(), 1, "size is not 1");
    }

    function testAddTwoRemoveFirst() {
        var mdd = new MockDatabaseDoug(true);
        var udb = new DefaultUserDatabase();
        udb.setDougAddress(address(mdd));

        udb.registerUser(TEST_ADDRESS, TEST_NICKNAME, TEST_TIMESTAMP, TEST_HASH);
        udb.registerUser(TEST_ADDRESS_2, TEST_NICKNAME_2, TEST_TIMESTAMP_2, TEST_HASH_2);
        udb.removeUser(TEST_ADDRESS);

        assertFalse(udb.hasUser(TEST_ADDRESS), "hasUser returned true for first user");
        assertTrue(udb.hasUser(TEST_ADDRESS_2), "hasUser returned false for second user");

        var (a, e) = udb.userAddressFromIndex(0);
        assertNoError(e, "userFromIndex returned an error for first user");
        assertAddressesEqual(a, TEST_ADDRESS_2, "userFromIndex address is wrong for first user");

        (a, e) = udb.userAddressFromIndex(1);
        assertErrorsEqual(e, ARRAY_INDEX_OUT_OF_BOUNDS, "userFromIndex did not return an 'array index out-of-bounds' for second user");
        assertAddressZero(a, "userFromIndex address is not zero for second user");

        var (nn, ts, dh) = udb.user(TEST_ADDRESS);
        assertBytes32Zero(nn, "first user returning the wrong nickname");
        assertUintZero(ts, "first user returning the wrong timestamp");
        assertBytes32Zero(dh, "first user returning the wrong data-hash");

        (nn, ts, dh) = udb.user(TEST_ADDRESS_2);
        assertBytes32Equal(nn, TEST_NICKNAME_2, "second user returning the wrong nickname");
        assertUintsEqual(ts, TEST_TIMESTAMP_2, "second user returning the wrong timestamp");
        assertBytes32Equal(dh, TEST_HASH_2, "second user returning the wrong data-hash");

        assertUintsEqual(udb.size(), 1, "size is not 1");
    }

    function testAddTwoRemoveBoth() {
        var mdd = new MockDatabaseDoug(true);
        var udb = new DefaultUserDatabase();
        udb.setDougAddress(address(mdd));

        udb.registerUser(TEST_ADDRESS, TEST_NICKNAME, TEST_TIMESTAMP, TEST_HASH);
        udb.registerUser(TEST_ADDRESS_2, TEST_NICKNAME_2, TEST_TIMESTAMP_2, TEST_HASH_2);
        udb.removeUser(TEST_ADDRESS);
        udb.removeUser(TEST_ADDRESS_2);

        assertFalse(udb.hasUser(TEST_ADDRESS), "hasUser returned true for first user");
        assertFalse(udb.hasUser(TEST_ADDRESS_2), "hasUser returned true for second user");

        var (a, e) = udb.userAddressFromIndex(0);
        assertErrorsEqual(e, ARRAY_INDEX_OUT_OF_BOUNDS, "userFromIndex did not return an 'array index out-of-bounds' for second user");

        var (nn, ts, dh) = udb.user(TEST_ADDRESS);
        assertBytes32Zero(nn, "first user returning the wrong nickname");
        assertUintZero(ts, "first user returning the wrong timestamp");
        assertBytes32Zero(dh, "first user returning the wrong data-hash");

        (nn, ts, dh) = udb.user(TEST_ADDRESS_2);
        assertBytes32Zero(nn, "second user returning the wrong nickname");
        assertUintZero(ts, "second user returning the wrong timestamp");
        assertBytes32Zero(dh, "second user returning the wrong data-hash");

        assertUintZero(udb.size(), "size is not 0");
    }

}