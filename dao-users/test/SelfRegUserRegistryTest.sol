import "./MockUserDatabase.sol";
import "dao-stl/src/assertions/DaoTest.sol";
import "dao-users/src/SelfRegUserRegistry.sol";

contract SelfRegUserRegistryTest is DaoTest {

    uint16 constant MOCK_RETURN = 0x1111;

    address constant TEST_ADDRESS = 0x12345;

    bytes32 constant TEST_NICKNAME = 0x1;

    bytes32 constant TEST_HASH = 0x11;

    function testCreate() {
        var srur = new SelfRegUserRegistry(TEST_ADDRESS, this);
        srur.admin().assertEqual(this, "The admin address is wrong.");
        srur.userDatabase().assertEqual(TEST_ADDRESS, "The user database is wrong");
    }

    function testRegisterSelfSuccess() {
        var mud = new MockUserDatabase(0, true, true, 0);
        var srur = new SelfRegUserRegistry(mud, this);
        var err = srur.registerSelf(TEST_NICKNAME, TEST_HASH);
        err.assertErrorsEqual(MOCK_RETURN, "registerUser returned the wrong error");
    }

    function testRegisterSelfFailNicknameIsNull() {
        var mud = new MockUserDatabase(0, true, true, 0);
        var srur = new SelfRegUserRegistry(mud, this);
        var err = srur.registerSelf(0, TEST_HASH);
        err.assertErrorsEqual(NULL_PARAM_NOT_ALLOWED, "registerUser returned the wrong error");
    }

}