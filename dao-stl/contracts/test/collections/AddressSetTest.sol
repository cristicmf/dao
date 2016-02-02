import "../../src/collections/AddressSet.slb";
import "../../src/assertions/Asserter.sol";

contract AddressSetDb {

    event AddAddress(bool indexed added);
    event RemoveAddress(bool indexed removed);

    using AddressSet for AddressSet.Set;

    AddressSet.Set _set;

    function addAddress(address addr) returns (bool added) {
        added = _set.insert(addr);
        AddAddress(added);
    }

    function removeAddress(address addr) returns (bool removed) {
        removed = _set.remove(addr);
        RemoveAddress(removed);
    }

    function hasAddress(address addr) constant returns (bool has) {
        return _set.hasValue(addr);
    }

    function addressFromIndex(uint index) constant returns (address addr, bool has) {
        return _set.valueFromIndex(index);
    }

    function numAddresses() constant returns (uint setSize) {
        return _set.size();
    }
}


contract AddressSetTest is Asserter {

    address constant TEST_ADDRESS = 0x12345;
    address constant TEST_ADDRESS_2 = 0xABCDEF;
    address constant TEST_ADDRESS_3 = 0xC0FFEE;

    function testInsert() {
        var asdb = new AddressSetDb();
        var added = asdb.addAddress(TEST_ADDRESS);
        assertTrue(added, "addAddress does not return true");
        assertTrue(asdb.hasAddress(TEST_ADDRESS), "hasAddress does not return true");
        var (a, e) = asdb.addressFromIndex(0);
        assertTrue(e, "addressFromIndex exist is false");
        assertAddressesEqual(a, TEST_ADDRESS, "addressFromIndex returns the wrong address");
    }

    function testRemoveAddress() {
        var asdb = new AddressSetDb();
        asdb.addAddress(TEST_ADDRESS);
        var removed = asdb.removeAddress(TEST_ADDRESS);
        assertTrue(removed, "removeAddress does not return true");
        assertFalse(asdb.hasAddress(TEST_ADDRESS), "hasAddress does not return false");
        var (a, e) = asdb.addressFromIndex(0);
        assertFalse(e, "addressFromIndex exist is true");
        assertAddressZero(a, "addressFromIndex returns non-zero address");
        assertUintZero(asdb.numAddresses(), "size is not zero");
    }

    function testAddTwoAddresses() {
        var asdb = new AddressSetDb();
        asdb.addAddress(TEST_ADDRESS);
        var added = asdb.addAddress(TEST_ADDRESS_2);
        assertTrue(added, "addAddress does not return true for second element");
        assertTrue(asdb.hasAddress(TEST_ADDRESS), "hasAddress does not return true for first element");
        assertTrue(asdb.hasAddress(TEST_ADDRESS_2), "hasAddress does not return true for second element");
        var (a, e) = asdb.addressFromIndex(0);
        assertTrue(e, "addressFromIndex exist is false for first element");
        assertAddressesEqual(a, TEST_ADDRESS, "addressFromIndex returns the wrong address for first element");
        (a, e) = asdb.addressFromIndex(1);
        assertTrue(e, "addressFromIndex exist is false for second element");
        assertAddressesEqual(a, TEST_ADDRESS_2, "addressFromIndex returns the wrong address for second element");

        assertUintsEqual(asdb.numAddresses(), 2, "size is not 2");
    }

    function testAddTwoAddressesRemoveLast() {
        var asdb = new AddressSetDb();
        asdb.addAddress(TEST_ADDRESS);
        asdb.addAddress(TEST_ADDRESS_2);
        asdb.removeAddress(TEST_ADDRESS_2);

        assertTrue(asdb.hasAddress(TEST_ADDRESS), "hasAddress does not return true for first element");
        assertFalse(asdb.hasAddress(TEST_ADDRESS_2), "hasAddress does not return false for second element");

        var (a, e) = asdb.addressFromIndex(0);
        assertTrue(e, "addressFromIndex exist is false for first element");
        assertAddressesEqual(a, TEST_ADDRESS, "addressFromIndex returns the wrong address for first element");
        (a, e) = asdb.addressFromIndex(1);
        assertFalse(e, "addressFromIndex exist is true for second element");
        assertAddressZero(a, "addressFromIndex returns the wrong address for second element");

        assertUintsEqual(asdb.numAddresses(), 1, "size is not 1");
    }

    function testAddTwoAddressesRemoveFirst() {
        var asdb = new AddressSetDb();
        asdb.addAddress(TEST_ADDRESS);
        asdb.addAddress(TEST_ADDRESS_2);
        asdb.removeAddress(TEST_ADDRESS);

        assertFalse(asdb.hasAddress(TEST_ADDRESS), "hasAddress does not return false for first element");
        assertTrue(asdb.hasAddress(TEST_ADDRESS_2), "hasAddress does not return true for second element");

        var (a, e) = asdb.addressFromIndex(0);
        assertTrue(e, "addressFromIndex exist is false for first element");
        assertAddressesEqual(a, TEST_ADDRESS_2, "addressFromIndex returns the wrong address for first element");
        (a, e) = asdb.addressFromIndex(1);
        assertFalse(e, "addressFromIndex exist is true for second element");
        assertAddressZero(a, "addressFromIndex returns the wrong address for second element");

        assertUintsEqual(asdb.numAddresses(), 1, "size is not 1");
    }

    function testAddThreeAddressesRemoveMiddle() {
        var asdb = new AddressSetDb();
        asdb.addAddress(TEST_ADDRESS);
        asdb.addAddress(TEST_ADDRESS_2);
        asdb.addAddress(TEST_ADDRESS_3);
        asdb.removeAddress(TEST_ADDRESS_2);

        assertTrue(asdb.hasAddress(TEST_ADDRESS), "hasAddress does not return true for first element");
        assertFalse(asdb.hasAddress(TEST_ADDRESS_2), "hasAddress does not return false for second element");
        assertTrue(asdb.hasAddress(TEST_ADDRESS_3), "hasAddress does not return true for third element");

        var (a, e) = asdb.addressFromIndex(0);
        assertTrue(e, "addressFromIndex exist is false for first element");
        assertAddressesEqual(a, TEST_ADDRESS, "addressFromIndex returns the wrong address for first element");

        (a, e) = asdb.addressFromIndex(1);
        assertTrue(e, "addressFromIndex exist is false for second element");
        assertAddressesEqual(a, TEST_ADDRESS_3, "addressFromIndex returns the wrong address for second element");

        (a, e) = asdb.addressFromIndex(2);
        assertFalse(e, "addressFromIndex exist is true for third element");
        assertAddressZero(a, "addressFromIndex returns the wrong address for third element");
    }

}