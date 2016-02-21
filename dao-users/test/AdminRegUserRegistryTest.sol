import "./MockUserDatabase.sol";
import "dao-stl/src/assertions/DaoTest.sol";
import "dao-users/src/AdminRegUserRegistry.sol";

contract AdminRegUserRegistryTest is DaoTest {

    uint16 constant MOCK_RETURN = 0x1111;

    address constant TEST_ADDRESS = 0x12345;

    bytes32 constant TEST_NICKNAME = 0x1;

    bytes32 constant TEST_HASH = 0x11;

    function testCreate() {
        var arur = new AdminRegUserRegistry(TEST_ADDRESS, this);
        arur.admin().assertEqual(this, "The admin address is wrong.");
        arur.userDatabase().assertEqual(TEST_ADDRESS, "The user database is wrong");
    }

    function testRegisterSelfAsAdmin() {
        var mud = new MockUserDatabase(0, true, true, 0);
        var arur = new AdminRegUserRegistry(mud, this);
        var err = arur.registerSelf(TEST_NICKNAME, TEST_HASH);
        err.assertErrorsEqual(MOCK_RETURN, "registerUser returned the wrong error");
    }

    function testRegisterSelfAsNonAdmin() {
        var mud = new MockUserDatabase(0, true, true, 0);
        var arur = new AdminRegUserRegistry(mud, TEST_ADDRESS);
        var err = arur.registerSelf(TEST_NICKNAME, TEST_HASH);
        err.assertErrorsEqual(ACCESS_DENIED, "registerUser returned the wrong error");
    }

    function testRegisterSelfFailNicknameIsNull() {
        var mud = new MockUserDatabase(0, true, true, 0);
        var arur = new AdminRegUserRegistry(mud, this);
        var err = arur.registerSelf(0, TEST_HASH);
        err.assertErrorsEqual(NULL_PARAM_NOT_ALLOWED, "registerUser returned the wrong error");
    }

}