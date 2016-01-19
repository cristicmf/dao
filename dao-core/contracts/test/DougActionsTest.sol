import "./DougBase.sol";

contract DougActionsTest is DaoAsserter {

    address constant TEST_ADDRESS = 0x12345;

    bytes32 constant TEST_BYTES32   = 1;
    bytes32 constant TEST_BYTES32_2 = 2;
    bytes32 constant TEST_BYTES32_3 = 3;

    function testAddActionsContract() {
        DefaultDoug doug = new DefaultDoug(new MockPermission(true), false, false);
        var mc = new MockContract();
        var err = doug.addActionsContract(TEST_BYTES32, address(mc));
        assertNoError(err, "addActionsContract returned error.");
        var cAddr = doug.actionsContractAddress(TEST_BYTES32);
        assertAddressesEqual(cAddr, address(mc), "actionsContractAddress returned the wrong address.");
        var (id, addr, errId) = doug.actionsContractFromIndex(0);
        assertBytes32Equal(id, TEST_BYTES32, "actionsContractAddress returned the wrong Id.");
        assertNoError(errId, "actionsContractFromIndex returned error.");
        assertBytes32Equal(doug.actionsContractId(address(mc)), TEST_BYTES32, "actionsContractId returned the wrong Id.");
        assertUintsEqual(doug.numActionsContracts(), 1, "size of actions contracts map is not 1");
    }

    function testAddActionsContractFailNotRoot() {
        DefaultDoug doug = new DefaultDoug(new MockPermission(false), false, false);
        var err = doug.addActionsContract(0, 0);
        assertErrorsEqual(err, ACCESS_DENIED, "addActionsContract did not return 'access denied' error");
    }

    function testAddActionsContractFailBadId() {
        DefaultDoug doug = new DefaultDoug(new MockPermission(true), false, false);
        var err = doug.addActionsContract(0, TEST_ADDRESS);
        assertErrorsEqual(err, NULL_PARAM_NOT_ALLOWED, "addActionsContract did not return 'null parameter' error");
    }

    function testAddActionsContractFailBadAddress() {
        DefaultDoug doug = new DefaultDoug(new MockPermission(true), false, false);
        var err = doug.addActionsContract(TEST_BYTES32, 0);
        assertErrorsEqual(err, NULL_PARAM_NOT_ALLOWED, "addActionsContract did not return 'null parameter' error");
    }

    // TODO
    // function testAddDatabaseContractFailContractNotDougEnabled() {}

    function testAddActionsContractOverwriteFail() {
        DefaultDoug doug = new DefaultDoug(new MockPermission(true), false, false);
        var mc = new MockContract();
        doug.addActionsContract(TEST_BYTES32, address(mc));
        var mc2 = new MockContract();
        var err = doug.addActionsContract(TEST_BYTES32, address(mc2));
        assertErrorsEqual(err, RESOURCE_ALREADY_EXISTS, "addActionsContract did not return 'resource exists' error.");
        var addr = doug.actionsContractAddress(TEST_BYTES32);
        assertAddressesEqual(addr, address(mc), "Address not correct.");
    }

    function testAddAndRemoveActionsContract() {
        DefaultDoug doug = new DefaultDoug(new MockPermission(true), false, false);
        var mc = new MockContract();
        var err = doug.addActionsContract(TEST_BYTES32, address(mc));
        assertNoError(err, "addActionsContract returned error.");
        err = doug.removeActionsContract(TEST_BYTES32);
        assertNoError(err, "removeActionsContract returned error.");

        assertAddressZero(doug.actionsContractAddress(TEST_BYTES32), "actionsContractAddress returned non-zero address.");
        assertBytes32Zero(doug.actionsContractId(address(mc)), "actionsContractId returned non-zero Id.");

        var (id, addr, errId) = doug.actionsContractFromIndex(0);
        assertBytes32Zero(id, "actionsContractFromIndex returned non-zero Id.");
        assertAddressZero(addr, "actionsContractFromIndex returned non-zero address.");
        assertErrorsEqual(errId, ARRAY_INDEX_OUT_OF_BOUNDS, "actionsContractFromIndex did not return 'array index out-of-bounds' error.");
        assertUintZero(doug.numActionsContracts(), "size of action contracts map is not zero");
    }

}