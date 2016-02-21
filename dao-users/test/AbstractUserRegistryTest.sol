import "./MockUserDatabase.sol";
import "dao-stl/src/assertions/DaoTest.sol";
import "dao-users/src/AbstractUserRegistry.sol";

contract AbstractUserRegistryImpl is AbstractUserRegistry {

    function AbstractUserRegistryImpl(address dbAddress, address admin) AbstractUserRegistry(dbAddress, admin) {}

    function registerSelf(bytes32 nickname, bytes32 dataHash) returns (uint16 error) {}

}

contract AbstractUserRegistryTest is DaoTest {

    uint16 constant MOCK_RETURN = 0x1111;

    address constant TEST_ADDRESS = 0x12345;
    address constant TEST_ADDRESS_2 = 0xABCDEF;

    bytes32 constant TEST_NICKNAME = 0x1;

    bytes32 constant TEST_HASH = 0x11;

    uint constant TEST_MAX_USERS = 1;

    function testCreate() {
        var auri = new AbstractUserRegistryImpl(TEST_ADDRESS, this);
        auri.admin().assertEqual(this, "The admin address is wrong.");
        auri.userDatabase().assertEqual(TEST_ADDRESS, "The user database is wrong");
    }

    function testRegisterUserSuccess() {
        var mud = new MockUserDatabase(0, true, true, 0);
        var auri = new AbstractUserRegistryImpl(mud, this);
        var err = auri.registerUser(TEST_ADDRESS, TEST_NICKNAME, TEST_HASH);
        err.assertErrorsEqual(MOCK_RETURN, "registerUser returned the wrong error");
    }

    function testRegisterUserFailNotAdmin() {
        var mud = new MockUserDatabase(0, true, true, 0);
        var auri = new AbstractUserRegistryImpl(mud, TEST_ADDRESS);
        var err = auri.registerUser(TEST_ADDRESS, TEST_NICKNAME, TEST_HASH);
        err.assertErrorsEqual(ACCESS_DENIED, "registerUser did not return 'access denied' error");
    }

    function testRegisterUserFailAddressIsNull() {
        var mud = new MockUserDatabase(0, true, true, 0);
        var auri = new AbstractUserRegistryImpl(mud, this);
        var err = auri.registerUser(0, TEST_NICKNAME, TEST_HASH);
        err.assertErrorsEqual(NULL_PARAM_NOT_ALLOWED, "registerUser did not return 'null param' error");
    }

    function testRegisterUserFailNicknameIsNull() {
        var mud = new MockUserDatabase(0, true, true, 0);
        var auri = new AbstractUserRegistryImpl(mud, this);
        var err = auri.registerUser(TEST_ADDRESS, 0, TEST_HASH);
        err.assertErrorsEqual(NULL_PARAM_NOT_ALLOWED, "registerUser did not return 'null param' error");
    }

    function testRemoveUserSuccessIsAdmin() {
        var mud = new MockUserDatabase(0, true, true, 0);
        var auri = new AbstractUserRegistryImpl(mud, this);
        var err = auri.removeUser(TEST_ADDRESS);
        err.assertErrorsEqual(MOCK_RETURN, "removeUser returned the wrong error");
    }

    function testRemoveUserSuccessIsUser() {
        var mud = new MockUserDatabase(0, true, true, 0);
        var auri = new AbstractUserRegistryImpl(mud, TEST_ADDRESS);
        var err = auri.removeUser(this);
        err.assertErrorsEqual(MOCK_RETURN, "removeUser returned the wrong error");
    }

    function testRemoveUserFailNotAdminOrUser() {
        var mud = new MockUserDatabase(0, true, true, 0);
        var auri = new AbstractUserRegistryImpl(mud, TEST_ADDRESS);
        var err = auri.removeUser(TEST_ADDRESS_2);
        err.assertErrorsEqual(ACCESS_DENIED, "removeUser did not return 'access denied' error");
    }

    function testRemoveUserFailAddressIsNull() {
        var mud = new MockUserDatabase(0, true, true, 0);
        var auri = new AbstractUserRegistryImpl(mud, this);
        var err = auri.removeUser(0);
        err.assertErrorsEqual(NULL_PARAM_NOT_ALLOWED, "removeUser did not return 'access denied' error");
    }

    function testRemoveSelf() {
        var mud = new MockUserDatabase(0, true, true, 0);
        var auri = new AbstractUserRegistryImpl(mud, TEST_ADDRESS);
        var err = auri.removeSelf();
        err.assertErrorsEqual(MOCK_RETURN, "removeSelf returned the wrong error");
    }

    function testUpdateDataHashSuccessIsAdmin() {
        var mud = new MockUserDatabase(0, true, true, 0);
        var auri = new AbstractUserRegistryImpl(mud, this);
        var err = auri.updateDataHash(TEST_ADDRESS, TEST_HASH);
        err.assertErrorsEqual(MOCK_RETURN, "updateDataHash returned the wrong error");
    }

    function testUpdateDataHashSuccessIsUser() {
        var mud = new MockUserDatabase(0, true, true, 0);
        var auri = new AbstractUserRegistryImpl(mud, TEST_ADDRESS);
        var err = auri.updateDataHash(this, TEST_HASH);
        err.assertErrorsEqual(MOCK_RETURN, "updateDataHash returned the wrong error");
    }

    function testUpdateDataHashFailNotAdminOrUser() {
        var mud = new MockUserDatabase(0, true, true, 0);
        var auri = new AbstractUserRegistryImpl(mud, TEST_ADDRESS);
        var err = auri.updateDataHash(TEST_ADDRESS_2, TEST_HASH);
        err.assertErrorsEqual(ACCESS_DENIED, "updateDataHash did not return 'access denied' error");
    }

    function testUpdateDataHashFailAddressIsNull() {
        var mud = new MockUserDatabase(0, true, true, 0);
        var auri = new AbstractUserRegistryImpl(mud, this);
        var err = auri.updateDataHash(0, TEST_HASH);
        err.assertErrorsEqual(NULL_PARAM_NOT_ALLOWED, "updateDataHash did not return 'access denied' error");
    }

    function testUpdateMyDataHash() {
        var mud = new MockUserDatabase(0, true, true, 0);
        var auri = new AbstractUserRegistryImpl(mud, TEST_ADDRESS);
        var err = auri.updateMyDataHash(TEST_HASH);
        err.assertErrorsEqual(MOCK_RETURN, "updateMyDataHash returned the wrong error");
    }

    function testSetPropertySuccessIsAdmin() {
        var mud = new MockUserDatabase(0, true, true, 0);
        var auri = new AbstractUserRegistryImpl(mud, this);
        var err = auri.setProperty(TEST_ADDRESS, TEST_HASH, true);
        err.assertErrorsEqual(MOCK_RETURN, "updateDataHash returned the wrong error");
    }

    function testSetPropertyFailNotAdmin() {
        var mud = new MockUserDatabase(0, true, true, 0);
        var auri = new AbstractUserRegistryImpl(mud, TEST_ADDRESS);
        var err = auri.setProperty(TEST_ADDRESS_2, TEST_HASH, true);
        err.assertErrorsEqual(ACCESS_DENIED, "updateDataHash did not return 'access denied' error");
    }

    function testSetPropertyFailAddressIsNull() {
        var mud = new MockUserDatabase(0, true, true, 0);
        var auri = new AbstractUserRegistryImpl(mud, this);
        var err = auri.setProperty(0, TEST_HASH, true);
        err.assertErrorsEqual(NULL_PARAM_NOT_ALLOWED, "updateDataHash did not return 'access denied' error");
    }

    function testSetPropertyFailPropertyIsNull() {
        var mud = new MockUserDatabase(0, true, true, 0);
        var auri = new AbstractUserRegistryImpl(mud, this);
        var err = auri.setProperty(TEST_ADDRESS, 0, true);
        err.assertErrorsEqual(NULL_PARAM_NOT_ALLOWED, "updateDataHash did not return 'access denied' error");
    }

    function testSetMaxUsersSuccess() {
        var mud = new MockUserDatabase(0, true, true, 0);
        var auri = new AbstractUserRegistryImpl(mud, this);
        var err = auri.setMaxUsers(TEST_MAX_USERS);
        err.assertErrorsEqual(MOCK_RETURN, "setMaxUsers returned the wrong error");
    }

    function testSetMaxUsersFailNotAdmin() {
        var auri = new AbstractUserRegistryImpl(0, TEST_ADDRESS);
        var err = auri.setMaxUsers(TEST_MAX_USERS);
        err.assertErrorsEqual(ACCESS_DENIED, "setMaxUsers returned the wrong error");
    }

    function testSetAdminSuccess() {
        var auri = new AbstractUserRegistryImpl(0, this);
        var err = auri.setAdmin(TEST_ADDRESS);
        err.assertNoError("setAdmin returned error");
        auri.admin().assertEqual(TEST_ADDRESS, "admin returns the wrong address");
    }

    function testSetAdminFailNotAdmin() {
        var auri = new AbstractUserRegistryImpl(0, TEST_ADDRESS);
        var err = auri.setAdmin(TEST_ADDRESS_2);
        err.assertErrorsEqual(ACCESS_DENIED, "setAdmin returned no 'access denied' error");
        auri.admin().assertEqual(TEST_ADDRESS, "admin returns the wrong address");
    }

    function testSetUserDatabaseSuccess() {
        var auri = new AbstractUserRegistryImpl(0, this);
        var err = auri.setUserDatabase(TEST_ADDRESS);
        err.assertNoError("setUserDatabase returned an error");
        auri.userDatabase().assertEqual(TEST_ADDRESS, "userDatabase returns the wrong address");
    }

    function testSetUserDatabaseFailNotAdmin() {
        var auri = new AbstractUserRegistryImpl(TEST_ADDRESS, TEST_ADDRESS_2);
        var err = auri.setUserDatabase(this);
        err.assertErrorsEqual(ACCESS_DENIED, "setUserDatabase did not return 'access denied' error");
        auri.userDatabase().assertEqual(TEST_ADDRESS, "userDatabase returns the wrong address");
    }

}