import "./MockUserDatabase.sol";
import "../../../dao-stl/contracts/src/assertions/DaoAsserter.sol";
import "../src/SelfRegUserRegistry.sol";

contract SelfRegUserRegistryTest is DaoAsserter {

    uint16 constant MOCK_RETURN = 0x1111;

    address constant TEST_ADDRESS = 0x12345;

    bytes32 constant TEST_NICKNAME = 0x1;

    bytes32 constant TEST_HASH = 0x11;

    function testCreate() {
        var srur = new SelfRegUserRegistry(TEST_ADDRESS, this);
        assertAddressesEqual(srur.admin(), this, "The admin address is wrong.");
        assertAddressesEqual(srur.userDatabase(), TEST_ADDRESS, "The user database is wrong");
    }

    function testRegisterSelfSuccess() {
        var mud = new MockUserDatabase(0, true, 0);
        var srur = new SelfRegUserRegistry(mud, this);
        var err = srur.registerSelf(TEST_NICKNAME, TEST_HASH);
        assertErrorsEqual(err, MOCK_RETURN, "registerUser returned the wrong error");
    }

    function testRegisterSelfFailNicknameIsNull() {
        var mud = new MockUserDatabase(0, true, 0);
        var srur = new SelfRegUserRegistry(mud, this);
        var err = srur.registerSelf(0, TEST_HASH);
        assertErrorsEqual(err, NULL_PARAM_NOT_ALLOWED, "registerUser returned the wrong error");
    }

}