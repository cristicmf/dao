import "./DougBase.sol";

contract DefaultDougTest is DaoAsserter {

    function testPermission() {
        var pm = new MockPermission(true);
        var doug = new DefaultDoug(pm, false, false);
        var pmAddr = doug.permissionAddress();
        assertAddressesEqual(pmAddr, address(pm), "permission address not correct");
    }

    function testBaseOptionsFalse() {
        var pm = new MockPermission(true);
        var doug = new DefaultDoug(pm, false, false);
        var dra = doug.destroyRemovedActions();
        assertFalse(dra, "destroy removed actions is true");
        var drd = doug.destroyRemovedDatabases();
        assertFalse(dra, "destroy removed databases is true");
    }

    function testBaseOptionsTrue() {
        var pm = new MockPermission(true);
        var doug = new DefaultDoug(pm, true, true);
        var dra = doug.destroyRemovedActions();
        assertTrue(dra, "destroy removed actions is false");
        var drd = doug.destroyRemovedDatabases();
        assertTrue(dra, "destroy removed databases is false");
    }

    function testSetDestroyRemovedActions() {
        var doug = new DefaultDoug(new MockPermission(true), false, false);
        var err = doug.setDestroyRemovedActions(true);
        assertNoError(err, "setDestroyRemovedActions returned error");
        var dra = doug.destroyRemovedActions();
        assertTrue(dra, "destroy removed actions is false");
    }

    function testSetDestroyRemovedActionsFailAccessDenied() {
        var doug = new DefaultDoug(new MockPermission(false), false, false);
        var err = doug.setDestroyRemovedActions(true);
        assertErrorsEqual(err, ACCESS_DENIED, "setDestroyRemovedActions did not return 'access denied' error.");
        var dra = doug.destroyRemovedActions();
        assertFalse(dra, "destroy removed actions is true");
    }

    function testSetDestroyRemovedDatabases() {
        var doug = new DefaultDoug(new MockPermission(true), false, false);
        var err = doug.setDestroyRemovedDatabases(true);
        assertNoError(err, "setDestroyRemovedDatabases returned error");
        var drd = doug.destroyRemovedDatabases();
        assertTrue(drd, "destroy removed databases is false");
    }

    function testSetDestroyRemovedDatabasesFailAccessDenied() {
        var doug = new DefaultDoug(new MockPermission(false), false, false);
        var err = doug.setDestroyRemovedDatabases(true);
        assertErrorsEqual(err, ACCESS_DENIED, "setDestroyRemovedActions did not return 'access denied' error.");
        var drd = doug.destroyRemovedDatabases();
        assertFalse(drd, "destroy removed databases is true");
    }

}