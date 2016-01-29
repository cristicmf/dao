import "./MockUserDatabase.sol";
import "../../../dao-stl/contracts/src/assertions/DaoAsserter.sol";
import "../src/AbstractUserRegistry.sol";

contract AbstractUserRegistryImpl is AbstractUserRegistry {

    AbstractUserRegistryImpl(address dbAddress, address admin) AbstractUserRegistry(dbAddress, admin) {}

    function registerSelf(bytes32 nickname, bytes32 dataHash) returns (uint16 error) {}

}

contract AbstractUserRegistryTest is DaoAsserter {

    address constant TEST_ADDRESS = 0x12345;
    address constant TEST_ADDRESS_2 = 0x54321;

    function testCreate() {
        var mud = new MockUserDatabase();
        var auri = new AbstractUserRegistryImpl(mud, this);

    }

}