import "./MockUserDatabase.sol";
import "../../../dao-stl/contracts/src/assertions/DaoAsserter.sol";
import "../src/AdminRegUserRegistry.sol";

contract AdminRegUserRegistryTest is DaoAsserter {

    uint16 constant MOCK_RETURN = 0x1111;

    address constant TEST_ADDRESS = 0x12345;

    bytes32 constant TEST_NICKNAME = 0x1;

    bytes32 constant TEST_HASH = 0x11;

    function testCreate() {
        var arur = new AdminRegUserRegistry(TEST_ADDRESS, this);
        assertAddressesEqual(arur.admin(), this, "The admin address is wrong.");
        assertAddressesEqual(arur.userDatabase(), TEST_ADDRESS, "The user database is wrong");
    }

    function testRegisterSelfAsAdmin() {
        var mud = new MockUserDatabase(0, true, 0);
        var arur = new AdminRegUserRegistry(mud, this);
        var err = arur.registerSelf(TEST_NICKNAME, TEST_HASH);
        assertErrorsEqual(err, MOCK_RETURN, "registerUser returned the wrong error");
    }

    function testRegisterSelfAsNonAdmin() {
        var mud = new MockUserDatabase(0, true, 0);
        var arur = new AdminRegUserRegistry(mud, TEST_ADDRESS);
        var err = arur.registerSelf(TEST_NICKNAME, TEST_HASH);
        assertErrorsEqual(err, ACCESS_DENIED, "registerUser returned the wrong error");
    }

    function testRegisterSelfFailNicknameIsNull() {
        var mud = new MockUserDatabase(0, true, 0);
        var arur = new AdminRegUserRegistry(mud, this);
        var err = arur.registerSelf(0, TEST_HASH);
        assertErrorsEqual(err, NULL_PARAM_NOT_ALLOWED, "registerUser returned the wrong error");
    }

}