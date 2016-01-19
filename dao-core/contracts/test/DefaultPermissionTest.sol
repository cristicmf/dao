import "../../../dao-stl/src/assertions/DaoAsserter.sol";
import "../src/DefaultPermission.sol";

// Timestamp tests must be done on "real" eth node or they'll always be 0.
contract DefaultPermissionTest is DaoAsserter {

    address constant TEST_ADDRESS = 0xFFFFFF;

    function testCreatePermission() {
        var p = new DefaultPermission(this);
        assertAddressesEqual(p.root(), address(this), "permissions root address is not the creator.");
    }

    function testSetRootSuccess() {
        var p = new DefaultPermission(this);
        var error = p.setRoot(TEST_ADDRESS);
        assertNoError(error, "Set root error");
        assertAddressesEqual(p.root(), TEST_ADDRESS, "permissions root address is not correct.");
    }

    function testSetRootFail() {
        var p = new DefaultPermission(TEST_ADDRESS);
        var error = p.setRoot(address(this));
        assertErrorsEqual(error, ACCESS_DENIED, "Access not denied.");
        assertAddressesEqual(p.root(), TEST_ADDRESS, "permissions root address is not the creator.");
    }

    function testRootData() {
        var (addr, time) = (new DefaultPermission(address(this))).rootData();
        assertAddressesEqual(addr, address(this), "permissions root address is not correct.");
        assertUintsEqual(time, block.timestamp, "timestamp not correct");
    }


    function testRootHasPermission() {
        var p = new DefaultPermission(address(this));
        assertTrue(p.hasPermission(address(this)), "Root does not have permission.");
    }

    function testAddOwnerSuccess() {
        var p = new DefaultPermission(address(this));
        var aErr = p.addOwner(TEST_ADDRESS);
        assertNoError(aErr, "addOwner returned error");
        var (oTime, oErr) = p.ownerTimestamp(TEST_ADDRESS);
        assertUintsEqual(oTime, block.timestamp, "owner timestamp not correct.");
        assertNoError(oErr, "ownerTimestamp returned error");
        var (,iErr) = p.ownerFromIndex(0);
        assertNoError(iErr, "ownerFromIndex returned error");
        assertTrue(p.hasPermission(TEST_ADDRESS), "owner does not have permission.");
    }

    function testAddOwnerFailBadAddress() {
        var p = new DefaultPermission(address(this));
        var aErr = p.addOwner(0);
        assertErrorsEqual(aErr, NULL_PARAM_NOT_ALLOWED, "addOwner did not return 'null param' error.");
        var (oTime, oErr) = p.ownerTimestamp(0);
        assertUintZero(oTime, "owner timestamp not zero.");
        assertErrorsEqual(oErr, RESOURCE_NOT_FOUND, "ownerTimestamp did not return 'not found' error.");
        var (,iErr) = p.ownerFromIndex(0);
        assertErrorsEqual(iErr, ARRAY_INDEX_OUT_OF_BOUNDS, "ownerTimestamp did not return 'array index out-of-bounds' error.");
        assertFalse(p.hasPermission(0), "null address is owner");
    }

    function testAddOwnerFailIsRoot() {
        var p = new DefaultPermission(address(this));
        var aErr = p.addOwner(address(this));
        assertErrorsEqual(aErr, INVALID_PARAM_VALUE, "addOwner did not return 'invalid param' error.");
        var (oTime, oErr) = p.ownerTimestamp(address(this));
        assertUintZero(oTime, "owner timestamp not zero.");
        assertErrorsEqual(oErr, RESOURCE_NOT_FOUND, "ownerTimestamp did not return 'not found' error.");
        var (,iErr) = p.ownerFromIndex(0);
        assertErrorsEqual(iErr, ARRAY_INDEX_OUT_OF_BOUNDS, "ownerTimestamp did not return 'array index out-of-bounds' error.");
    }

    function testAddOwnerFailNoPerm() {
        var p = new DefaultPermission(TEST_ADDRESS);
        var aErr = p.addOwner(address(this));
        assertErrorsEqual(aErr, ACCESS_DENIED, "addOwner did not return 'access denied' error.");
        var (oTime, oErr) = p.ownerTimestamp(address(this));
        assertUintZero(oTime, "owner timestamp not zero.");
        assertErrorsEqual(oErr, RESOURCE_NOT_FOUND, "ownerTimestamp did not return 'not found' error.");
        var (,iErr) = p.ownerFromIndex(0);
        assertErrorsEqual(iErr, ARRAY_INDEX_OUT_OF_BOUNDS, "ownerTimestamp did not return 'array index out-of-bounds' error.");
    }

    function testAddOwnerFailAlreadyExists() {
        var p = new DefaultPermission(address(this));
        var aErr = p.addOwner(TEST_ADDRESS);
        aErr = p.addOwner(TEST_ADDRESS);
        assertErrorsEqual(aErr, RESOURCE_ALREADY_EXISTS, "addOwner did not return 'resource exists' error.");
        var (oTime, oErr) = p.ownerTimestamp(TEST_ADDRESS);
        assertUintNotZero(oTime, "owner timestamp is zero.");
        assertNoError(oErr, "ownerTimestamp returned errror");
        var (,iErr) = p.ownerFromIndex(0);
        assertNoError(iErr, "ownerFromIndex(0) returned error");
        assertTrue(p.hasPermission(TEST_ADDRESS), "owner does not have permission");
    }

}