import "./DougBase.sol";

contract DefaultDougEnabledTest is DaoAsserter {

    address constant TEST_ADDRESS = 0x12345;
    address constant TEST_ADDRESS_2 = 0x23456;

    function testSetDougSuccess() {
        var dds = new DefaultDougSettable(0);
        var ret = dds.setDougAddress(TEST_ADDRESS);
        assertAddressesEqual(ret, TEST_ADDRESS, "setDougAddress returned false");
        assertAddressesEqual(dds.dougAddress(), TEST_ADDRESS, "dougAddress returns wrong address.");
    }

    function testSetDougFailNullArgument() {
        var dds = new DefaultDougSettable(0);
        var ret = dds.setDougAddress(0);
        assertAddressZero(ret, "setDougAddress returned wrong value");
    }

    function testSetDougFailAlreadySet() {
        var dds = new DefaultDougSettable(TEST_ADDRESS);
        var ret = dds.setDougAddress(TEST_ADDRESS_2);
        assertAddressesEqual(ret, TEST_ADDRESS, "setDougAddress returned wrong value");
    }

    function testSetDougSuccessDougIsCaller() {
        var dds = new DefaultDougSettable(address(this));
        var ret = dds.setDougAddress(TEST_ADDRESS);
        assertAddressesEqual(ret, TEST_ADDRESS, "setDougAddress returned false");
        assertAddressesEqual(dds.dougAddress(), TEST_ADDRESS, "dougAddress returns wrong address.");
    }

}