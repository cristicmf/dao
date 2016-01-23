import "./DougBase.sol";

contract DefaultDougDatabaseTest is DaoAsserter {

    address constant TEST_ADDRESS = 0x12345;

    bytes32 constant TEST_BYTES32   = 1;
    bytes32 constant TEST_BYTES32_2 = 2;
    bytes32 constant TEST_BYTES32_3 = 3;

    function testAddDatabaseContract() {
        DefaultDoug doug = new DefaultDoug(new MockPermission(true), false, false);
        var mc = new MockContract();
        var err = doug.addDatabaseContract(TEST_BYTES32, address(mc));
        assertNoError(err, "addDatabaseContract returned error.");
        var cAddr = doug.databaseContractAddress(TEST_BYTES32);
        assertAddressesEqual(cAddr, address(mc), "databaseContractAddress returned the wrong address.");
        var (id, addr, errId) = doug.databaseContractFromIndex(0);
        assertBytes32Equal(id, TEST_BYTES32, "databaseContractAddress returned the wrong Id.");
        assertNoError(errId, "databaseContractFromIndex returned error.");
        assertBytes32Equal(doug.databaseContractId(address(mc)), TEST_BYTES32, "databaseContractId returned the wrong Id.");
        assertUintsEqual(doug.numDatabaseContracts(), 1, "size of database contracts map is not 1");
    }

    function testAddDatabaseContractFailNotRoot() {
        DefaultDoug doug = new DefaultDoug(new MockPermission(false), false, false);
        var err = doug.addDatabaseContract(0, 0);
        assertErrorsEqual(err, ACCESS_DENIED, "addDatabaseContract did not return 'access denied' error");
    }

    function testAddDatabaseContractFailBadId() {
        DefaultDoug doug = new DefaultDoug(new MockPermission(true), false, false);
        var err = doug.addDatabaseContract(0, TEST_ADDRESS);
        assertErrorsEqual(err, NULL_PARAM_NOT_ALLOWED, "addDatabaseContract did not return 'null parameter' error");
    }

    function testAddDatabaseContractFailBadAddress() {
        DefaultDoug doug = new DefaultDoug(new MockPermission(true), false, false);
        var err = doug.addDatabaseContract(TEST_BYTES32, 0);
        assertErrorsEqual(err, NULL_PARAM_NOT_ALLOWED, "addDatabaseContract did not return 'null parameter' error");
    }

    // TODO
    // function testAddDatabaseContractFailContractNotDougEnabled() {}

    function testAddDatabaseContractOverwriteFail() {
        DefaultDoug doug = new DefaultDoug(new MockPermission(true), false, false);
        var mc = new MockContract();
        doug.addDatabaseContract(TEST_BYTES32, address(mc));
        var mc2 = new MockContract();
        var err = doug.addDatabaseContract(TEST_BYTES32, address(mc2));
        assertErrorsEqual(err, RESOURCE_ALREADY_EXISTS, "addDatabaseContract did not return 'resource exists' error.");
        var addr = doug.databaseContractAddress(TEST_BYTES32);
        assertAddressesEqual(addr, address(mc), "Address not correct.");
    }

    function testAddAndRemoveDatabaseContract() {
        DefaultDoug doug = new DefaultDoug(new MockPermission(true), false, false);
        var mc = new MockContract();
        var err = doug.addDatabaseContract(TEST_BYTES32, address(mc));
        assertNoError(err, "addDatabaseContract returned error.");
        err = doug.removeDatabaseContract(TEST_BYTES32);
        assertNoError(err, "removeDatabaseContract returned error.");

        assertAddressZero(doug.databaseContractAddress(TEST_BYTES32), "databaseContractAddress returned non-zero address.");
        assertBytes32Zero(doug.databaseContractId(address(mc)), "databaseContractId returned non-zero Id.");

        var (id, addr, errId) = doug.databaseContractFromIndex(0);
        assertBytes32Zero(id, "databaseContractFromIndex returned non-zero Id.");
        assertAddressZero(addr, "databaseContractFromIndex returned non-zero address.");
        assertErrorsEqual(errId, ARRAY_INDEX_OUT_OF_BOUNDS, "databaseContractFromIndex did not return 'array index out-of-bounds' error.");
        assertUintZero(doug.numDatabaseContracts(), "size of action contracts map is not zero");
    }

}