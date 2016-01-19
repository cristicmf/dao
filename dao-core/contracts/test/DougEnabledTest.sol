import "./DougBase.sol";

contract DougEnabledTest is DaoAsserter {

    address constant TEST_ADDRESS = 0x12345;
    address constant TEST_ADDRESS_2 = 0x23456;

    function testSetDougSuccess() {
        var dds = new DefaultDougSettable(0);
        var result = dds.setDougAddress(TEST_ADDRESS);
        assertTrue(result, "setDougAddress returned false");
        assertAddressesEqual(dds.dougAddress(), TEST_ADDRESS, "dougAddress returns wrong address.");
    }

    function testSetDougFailNullArgument() {
        var dds = new DefaultDougSettable(0);
        var result = dds.setDougAddress(0);
        assertFalse(result, "setDougAddress returned true");
    }

    function testSetDougFailAlreadySet() {
        var dds = new DefaultDougSettable(TEST_ADDRESS_2);
        var result = dds.setDougAddress(TEST_ADDRESS);
        assertFalse(result, "setDougAddress returned true");
        assertAddressesEqual(dds.dougAddress(), TEST_ADDRESS_2, "dougAddress returns wrong address.");
    }

    function testSetDougSuccessDougIsCaller() {
        var dds = new DefaultDougSettable(address(this));
        var result = dds.setDougAddress(TEST_ADDRESS);
        assertTrue(result, "setDougAddress returned false");
        assertAddressesEqual(dds.dougAddress(), TEST_ADDRESS, "dougAddress returns wrong address.");
    }

}