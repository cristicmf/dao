import "dao-users/src/DefaultUserDatabase.sol";
import "dao-stl/src/assertions/DaoTest.sol";
import "dao-core/test/MockDatabaseDoug.sol";

contract DefaultUserDatabaseTest is DaoTest {

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
    
    uint constant TEST_MAX_SIZE = 1;

    function testSetMaxSizeSuccess() {
        var mdd = new MockDatabaseDoug(true);
        var udb = new DefaultUserDatabase();
        udb.setDougAddress(mdd);
        udb.setMaxSize(TEST_MAX_SIZE).assertNoError("setMaxSize returned an error");
        udb.maxSize().assertEqual(TEST_MAX_SIZE, "maxSize returns the wrong value");
    }

    function testSetMaxSizeFailNotActions() {
        var mdd = new MockDatabaseDoug(false);
        var udb = new DefaultUserDatabase();
        udb.setDougAddress(mdd);
        udb.setMaxSize(TEST_MAX_SIZE).assertErrorsEqual(ACCESS_DENIED, "setMaxSize returned the wrong error");
    }

    function testSetMaxSizeFailTooManyUsers() {
        var mdd = new MockDatabaseDoug(true);
        var udb = new DefaultUserDatabase();
        udb.setDougAddress(mdd);
        udb.registerUser(TEST_ADDRESS, TEST_NICKNAME, TEST_TIMESTAMP, TEST_HASH);
        udb.registerUser(TEST_ADDRESS_2, TEST_NICKNAME_2, TEST_TIMESTAMP_2, TEST_HASH_2);
        udb.setMaxSize(TEST_MAX_SIZE).assertErrorsEqual(INTEGER_OUT_OF_BOUNDS, "setMaxSize returned the wrong error");
    }

    function testSetMaxSizeToZeroSuccessDespiteUsers() {
        var mdd = new MockDatabaseDoug(true);
        var udb = new DefaultUserDatabase();
        udb.setDougAddress(mdd);
        udb.registerUser(TEST_ADDRESS, TEST_NICKNAME, TEST_TIMESTAMP, TEST_HASH);
        udb.registerUser(TEST_ADDRESS_2, TEST_NICKNAME_2, TEST_TIMESTAMP_2, TEST_HASH_2);
        udb.setMaxSize(0).assertNoError("setMaxSize returned the wrong error");
    }

    function testRegister() {
        var mdd = new MockDatabaseDoug(true);
        var udb = new DefaultUserDatabase();
        udb.setDougAddress(mdd);
        
        udb.registerUser(TEST_ADDRESS, TEST_NICKNAME, TEST_TIMESTAMP, TEST_HASH);
        udb.hasUser(TEST_ADDRESS).assert("hasUser returned false");

        var (a, e) = udb.userAddressFromIndex(0);
        e.assertNoError("userFromIndex returned an error");
        a.assertEqual(TEST_ADDRESS, "userFromIndex address is wrong");

        var (nn, ts, dh) = udb.user(TEST_ADDRESS);
        nn.assertEqual(TEST_NICKNAME, "user returning the wrong nickname");
        ts.assertEqual(TEST_TIMESTAMP, "user returning the wrong timestamp");
        dh.assertEqual(TEST_HASH, "user returning the wrong data-hash");
        udb.size().assertEqual(1, "size is not 1");
    }


    function testRegisterFailNotActions() {
        var mdd = new MockDatabaseDoug(false);
        var udb = new DefaultUserDatabase();
        udb.setDougAddress(mdd);

        var err = udb.registerUser(TEST_ADDRESS, TEST_NICKNAME, TEST_TIMESTAMP, 0);
        err.assertErrorsEqual(ACCESS_DENIED, "registerUser did not return an 'access denied' error");

    }

    function testOverwriteFail() {
        var udb = new DefaultUserDatabase();
        udb.setDougAddress(address(this));

        udb.registerUser(TEST_ADDRESS, TEST_NICKNAME, TEST_TIMESTAMP, TEST_HASH);
        var aErr = udb.registerUser(TEST_ADDRESS, TEST_NICKNAME_2, TEST_TIMESTAMP_2, TEST_HASH_2);
        aErr.assertErrorsEqual(RESOURCE_ALREADY_EXISTS, "registerUser returned no error");
        var (nn, ts, dh) = udb.user(TEST_ADDRESS);
        nn.assertEqual(TEST_NICKNAME, "user returning the wrong nickname");
        ts.assertEqual(TEST_TIMESTAMP, "user returning the wrong timestamp");
        dh.assertEqual(TEST_HASH, "user returning the wrong data-hash");
        udb.size().assertEqual(1, "size is not 1");
    }

    function testRemove() {
        var mdd = new MockDatabaseDoug(true);
        var udb = new DefaultUserDatabase();
        udb.setDougAddress(mdd);

        udb.registerUser(TEST_ADDRESS, TEST_NICKNAME, TEST_TIMESTAMP, TEST_HASH);
        udb.removeUser(TEST_ADDRESS);
        udb.hasUser(TEST_ADDRESS).assertFalse("hasUser returned true");
        var (a, e) = udb.userAddressFromIndex(0);
        e.assertErrorsEqual(ARRAY_INDEX_OUT_OF_BOUNDS, "userFromIndex returned no 'array index out-of-bounds' error");
        a.assertZero("userFromIndex address is not null");
        var (nn, ts, dh) = udb.user(TEST_ADDRESS);
        nn.assertZero("user returning the wrong nickname");
        ts.assertZero("user returning the wrong timestamp");
        dh.assertZero("user returning the wrong data-hash");
        udb.size().assertZero("size is not 0");
    }

    function testRemoveFailNotActions() {
        var mdd = new MockDatabaseDoug(false);
        var udb = new DefaultUserDatabase();
        udb.setDougAddress(mdd);

        var err = udb.removeUser(TEST_ADDRESS);
        err.assertErrorsEqual(ACCESS_DENIED, "registerUser did not return an 'access denied' error");
    }

    function testUpdateDataHash() {
        var mdd = new MockDatabaseDoug(true);
        var udb = new DefaultUserDatabase();
        udb.setDougAddress(mdd);

        udb.registerUser(TEST_ADDRESS, TEST_NICKNAME, TEST_TIMESTAMP, TEST_HASH);

        var err = udb.updateDataHash(TEST_ADDRESS, TEST_HASH_2);
        err.assertNoError("updateDataHash returned an error");

        var (, dh) = udb.user(TEST_ADDRESS);
        dh.assertEqual(TEST_HASH_2, "user returning the wrong data-hash");
    }

    function testUpdateDataHashFailNotActions() {
        var mdd = new MockDatabaseDoug(false);
        var udb = new DefaultUserDatabase();
        udb.setDougAddress(mdd);

        udb.registerUser(TEST_ADDRESS, TEST_NICKNAME, TEST_TIMESTAMP, TEST_HASH);

        var err = udb.updateDataHash(TEST_ADDRESS, TEST_HASH_2);
        err.assertErrorsEqual(ACCESS_DENIED, "updateDataHash did not return an 'access denied' error");
    }

    function testRegisterTwo() {

        var mdd = new MockDatabaseDoug(true);
        var udb = new DefaultUserDatabase();
        udb.setDougAddress(mdd);

        var aErr = udb.registerUser(TEST_ADDRESS, TEST_NICKNAME, TEST_TIMESTAMP, TEST_HASH);
        aErr.assertNoError("Registering first user returned error");
        var aErr2 = udb.registerUser(TEST_ADDRESS_2, TEST_NICKNAME_2, TEST_TIMESTAMP_2, TEST_HASH_2);
        aErr2.assertNoError("Registering second user returned error");

        udb.hasUser(TEST_ADDRESS).assert("hasUser returned false for first user");
        udb.hasUser(TEST_ADDRESS_2).assert("hasUser returned false for second user");

        var (a, e) = udb.userAddressFromIndex(0);
        e.assertNoError("userFromIndex returned an error for first user");
        a.assertEqual(TEST_ADDRESS, "userFromIndex address is wrong for first user");

        (a, e) = udb.userAddressFromIndex(1);
        e.assertNoError("userFromIndex returned an error for second user");
        a.assertEqual(TEST_ADDRESS_2, "userFromIndex address is wrong for second user");

        var (nn, ts, dh) = udb.user(TEST_ADDRESS);
        nn.assertEqual(TEST_NICKNAME, "first user returning the wrong nickname");
        ts.assertEqual(TEST_TIMESTAMP, "first user returning the wrong timestamp");
        dh.assertEqual(TEST_HASH, "first user returning the wrong data-hash");

        (nn, ts, dh) = udb.user(TEST_ADDRESS_2);
        nn.assertEqual(TEST_NICKNAME_2, "second user returning the wrong nickname");
        ts.assertEqual(TEST_TIMESTAMP_2, "second user returning the wrong timestamp");
        dh.assertEqual(TEST_HASH_2, "second user returning the wrong data-hash");

        udb.size().assertEqual(2, "size is not 2");
    }

    function testRegisterTwoRemoveLast() {
        var mdd = new MockDatabaseDoug(true);
        var udb = new DefaultUserDatabase();
        udb.setDougAddress(mdd);

        udb.registerUser(TEST_ADDRESS, TEST_NICKNAME, TEST_TIMESTAMP, TEST_HASH);
        udb.registerUser(TEST_ADDRESS_2, TEST_NICKNAME_2, TEST_TIMESTAMP_2, TEST_HASH_2);
        udb.removeUser(TEST_ADDRESS_2);

        udb.hasUser(TEST_ADDRESS).assert("hasUser returned false for first user");
        udb.hasUser(TEST_ADDRESS_2).assertFalse("hasUser returned true for second user");

        var (a, e) = udb.userAddressFromIndex(0);
        e.assertNoError("userFromIndex returned an error for first user");
        a.assertEqual(TEST_ADDRESS, "userFromIndex address is wrong for first user");

        (a, e) = udb.userAddressFromIndex(1);
        e.assertErrorsEqual(ARRAY_INDEX_OUT_OF_BOUNDS, "userFromIndex did not return an 'array index out-of-bounds' for second user");
        a.assertZero("userFromIndex address is not zero for second user");

        var (nn, ts, dh) = udb.user(TEST_ADDRESS);
        nn.assertEqual(TEST_NICKNAME, "first user returning the wrong nickname");
        ts.assertEqual(TEST_TIMESTAMP, "first user returning the wrong timestamp");
        dh.assertEqual(TEST_HASH, "first user returning the wrong data-hash");

        (nn, ts, dh) = udb.user(TEST_ADDRESS_2);
        nn.assertZero("second user returning the wrong nickname");
        ts.assertZero("second user returning the wrong timestamp");
        dh.assertZero("second user returning the wrong data-hash");

        udb.size().assertEqual(1, "size is not 1");
    }

    function testRegisterTwoRemoveFirst() {
        var mdd = new MockDatabaseDoug(true);
        var udb = new DefaultUserDatabase();
        udb.setDougAddress(mdd);

        udb.registerUser(TEST_ADDRESS, TEST_NICKNAME, TEST_TIMESTAMP, TEST_HASH);
        udb.registerUser(TEST_ADDRESS_2, TEST_NICKNAME_2, TEST_TIMESTAMP_2, TEST_HASH_2);
        udb.removeUser(TEST_ADDRESS);

        udb.hasUser(TEST_ADDRESS).assertFalse("hasUser returned true for first user");
        udb.hasUser(TEST_ADDRESS_2).assert("hasUser returned false for second user");

        var (a, e) = udb.userAddressFromIndex(0);
        e.assertNoError("userFromIndex returned an error for first user");
        a.assertEqual(TEST_ADDRESS_2, "userFromIndex address is wrong for first user");

        (a, e) = udb.userAddressFromIndex(1);
        e.assertErrorsEqual(ARRAY_INDEX_OUT_OF_BOUNDS, "userFromIndex did not return an 'array index out-of-bounds' for second user");
        a.assertZero("userFromIndex address is not zero for second user");

        var (nn, ts, dh) = udb.user(TEST_ADDRESS);
        nn.assertZero("first user returning the wrong nickname");
        ts.assertZero("first user returning the wrong timestamp");
        dh.assertZero("first user returning the wrong data-hash");

        (nn, ts, dh) = udb.user(TEST_ADDRESS_2);
        nn.assertEqual(TEST_NICKNAME_2, "second user returning the wrong nickname");
        ts.assertEqual(TEST_TIMESTAMP_2, "second user returning the wrong timestamp");
        dh.assertEqual(TEST_HASH_2, "second user returning the wrong data-hash");

        udb.size().assertEqual(1, "size is not 1");
    }

    function testRegisterTwoRemoveBoth() {
        var mdd = new MockDatabaseDoug(true);
        var udb = new DefaultUserDatabase();
        udb.setDougAddress(mdd);

        udb.registerUser(TEST_ADDRESS, TEST_NICKNAME, TEST_TIMESTAMP, TEST_HASH);
        udb.registerUser(TEST_ADDRESS_2, TEST_NICKNAME_2, TEST_TIMESTAMP_2, TEST_HASH_2);
        udb.removeUser(TEST_ADDRESS);
        udb.removeUser(TEST_ADDRESS_2);

        udb.hasUser(TEST_ADDRESS).assertFalse("hasUser returned true for first user");
        udb.hasUser(TEST_ADDRESS_2).assertFalse("hasUser returned true for second user");

        var (a, e) = udb.userAddressFromIndex(0);
        e.assertErrorsEqual(ARRAY_INDEX_OUT_OF_BOUNDS, "userFromIndex did not return an 'array index out-of-bounds' for second user");

        var (nn, ts, dh) = udb.user(TEST_ADDRESS);
        nn.assertZero("first user returning the wrong nickname");
        ts.assertZero("first user returning the wrong timestamp");
        dh.assertZero("first user returning the wrong data-hash");

        (nn, ts, dh) = udb.user(TEST_ADDRESS_2);
        nn.assertZero("second user returning the wrong nickname");
        ts.assertZero("second user returning the wrong timestamp");
        dh.assertZero("second user returning the wrong data-hash");

        udb.size().assertZero("size is not 0");
    }

}