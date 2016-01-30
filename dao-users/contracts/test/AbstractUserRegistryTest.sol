import "./MockUserDatabase.sol";
import "../../../dao-stl/contracts/src/assertions/DaoAsserter.sol";
import "../src/AbstractUserRegistry.sol";

contract AbstractUserRegistryImpl is AbstractUserRegistry {

    function AbstractUserRegistryImpl(address dbAddress, address admin) AbstractUserRegistry(dbAddress, admin) {}

    function registerSelf(bytes32 nickname, bytes32 dataHash) returns (uint16 error) {}

}

contract AbstractUserRegistryTest is DaoAsserter {

    uint16 constant MOCK_RETURN = 0x1111;

    address constant TEST_ADDRESS = 0x12345;
    address constant TEST_ADDRESS_2 = 0xABCDEF;

    bytes32 constant TEST_NICKNAME = 0x1;

    bytes32 constant TEST_HASH = 0x11;

    function testCreate() {
        var auri = new AbstractUserRegistryImpl(TEST_ADDRESS, this);
        assertAddressesEqual(auri.admin(), this, "The admin address is wrong.");
        assertAddressesEqual(auri.userDatabase(), TEST_ADDRESS, "The user database is wrong");
    }

    function testRegisterUserSuccess() {
        var mud = new MockUserDatabase(0, true, 0);
        var auri = new AbstractUserRegistryImpl(mud, this);
        var err = auri.registerUser(TEST_ADDRESS, TEST_NICKNAME, TEST_HASH);
        assertErrorsEqual(err, MOCK_RETURN, "registerUser returned the wrong error");
    }

    function testRegisterUserFailNotAdmin() {
        var mud = new MockUserDatabase(0, true, 0);
        var auri = new AbstractUserRegistryImpl(mud, TEST_ADDRESS);
        var err = auri.registerUser(TEST_ADDRESS, TEST_NICKNAME, TEST_HASH);
        assertErrorsEqual(err, ACCESS_DENIED, "registerUser did not return 'access denied' error");
    }

    function testRegisterUserFailAddressIsNull() {
        var mud = new MockUserDatabase(0, true, 0);
        var auri = new AbstractUserRegistryImpl(mud, this);
        var err = auri.registerUser(0, TEST_NICKNAME, TEST_HASH);
        assertErrorsEqual(err, NULL_PARAM_NOT_ALLOWED, "registerUser did not return 'null param' error");
    }

    function testRegisterUserFailNicknameIsNull() {
        var mud = new MockUserDatabase(0, true, 0);
        var auri = new AbstractUserRegistryImpl(mud, this);
        var err = auri.registerUser(TEST_ADDRESS, 0, TEST_HASH);
        assertErrorsEqual(err, NULL_PARAM_NOT_ALLOWED, "registerUser did not return 'null param' error");
    }

    function testRemoveUserSuccessIsAdmin() {
        var mud = new MockUserDatabase(0, true, 0);
        var auri = new AbstractUserRegistryImpl(mud, this);
        var err = auri.removeUser(TEST_ADDRESS);
        assertErrorsEqual(err, MOCK_RETURN, "removeUser returned an error");
    }

    function testRemoveUserSuccessIsUser() {
        var mud = new MockUserDatabase(0, true, 0);
        var auri = new AbstractUserRegistryImpl(mud, TEST_ADDRESS);
        var err = auri.removeUser(this);
        assertErrorsEqual(err, MOCK_RETURN, "removeUser returned an error");
    }

    function testRemoveUserFailNotAdminOrUser() {
        var mud = new MockUserDatabase(0, true, 0);
        var auri = new AbstractUserRegistryImpl(mud, TEST_ADDRESS);
        var err = auri.removeUser(TEST_ADDRESS_2);
        assertErrorsEqual(err, ACCESS_DENIED, "removeUser did not return 'access denied' error");
    }

    function testRemoveUserFailAddressIsNull() {
        var mud = new MockUserDatabase(0, true, 0);
        var auri = new AbstractUserRegistryImpl(mud, this);
        var err = auri.removeUser(0);
        assertErrorsEqual(err, NULL_PARAM_NOT_ALLOWED, "removeUser did not return 'access denied' error");
    }

    function testRemoveSelf() {
        var mud = new MockUserDatabase(0, true, 0);
        var auri = new AbstractUserRegistryImpl(mud, TEST_ADDRESS);
        var err = auri.removeSelf();
        assertErrorsEqual(err, MOCK_RETURN, "removeSelf returned an error");
    }

    function testUpdateDataHashSuccessIsAdmin() {
        var mud = new MockUserDatabase(0, true, 0);
        var auri = new AbstractUserRegistryImpl(mud, this);
        var err = auri.updateDataHash(TEST_ADDRESS, TEST_HASH);
        assertErrorsEqual(err, MOCK_RETURN, "updateDataHash returned an error");
    }

    function testUpdateDataHashSuccessIsUser() {
        var mud = new MockUserDatabase(0, true, 0);
        var auri = new AbstractUserRegistryImpl(mud, TEST_ADDRESS);
        var err = auri.updateDataHash(this, TEST_HASH);
        assertErrorsEqual(err, MOCK_RETURN, "updateDataHash returned an error");
    }

    function testUpdateDataHashFailNotAdminOrUser() {
        var mud = new MockUserDatabase(0, true, 0);
        var auri = new AbstractUserRegistryImpl(mud, TEST_ADDRESS);
        var err = auri.updateDataHash(TEST_ADDRESS_2, TEST_HASH);
        assertErrorsEqual(err, ACCESS_DENIED, "updateDataHash did not return 'access denied' error");
    }

    function testUpdateDataHashFailAddressIsNull() {
        var mud = new MockUserDatabase(0, true, 0);
        var auri = new AbstractUserRegistryImpl(mud, this);
        var err = auri.updateDataHash(0, TEST_HASH);
        assertErrorsEqual(err, NULL_PARAM_NOT_ALLOWED, "updateDataHash did not return 'access denied' error");
    }

    function testUpdateMyDataHash() {
        var mud = new MockUserDatabase(0, true, 0);
        var auri = new AbstractUserRegistryImpl(mud, TEST_ADDRESS);
        var err = auri.updateMyDataHash(TEST_HASH);
        assertErrorsEqual(err, MOCK_RETURN, "removeSelf returned an error");
    }

    function testSetAdminSuccess() {
        var auri = new AbstractUserRegistryImpl(0, this);
        var err = auri.setAdmin(TEST_ADDRESS);
        assertNoError(err, "setAdmin returned error");
        assertAddressesEqual(auri.admin(), TEST_ADDRESS, "admin returns the wrong address");
    }

    function testSetAdminFailAccessDenied() {
        var auri = new AbstractUserRegistryImpl(0, TEST_ADDRESS);
        var err = auri.setAdmin(TEST_ADDRESS_2);
        assertErrorsEqual(err, ACCESS_DENIED, "setAdmin returned no 'access denied' error");
        assertAddressesEqual(auri.admin(), TEST_ADDRESS, "admin returns the wrong address");
    }

    function testSetUserDatabaseSuccess() {
        var auri = new AbstractUserRegistryImpl(0, this);
        var err = auri.setUserDatabase(TEST_ADDRESS);
        assertNoError(err, "setUserDatabase returned an error");
        var cd = auri.userDatabase();
        assertAddressesEqual(cd, TEST_ADDRESS, "userDatabase returns the wrong address");
    }

    function testSetUserDatabaseFailNotAdmin() {
        var auri = new AbstractUserRegistryImpl(TEST_ADDRESS, TEST_ADDRESS_2);
        var err = auri.setUserDatabase(this);
        assertErrorsEqual(err, ACCESS_DENIED, "setUserDatabase did not return 'access denied' error");
        var cd = auri.userDatabase();
        assertAddressesEqual(cd, TEST_ADDRESS, "userDatabase returns the wrong address");
    }

}