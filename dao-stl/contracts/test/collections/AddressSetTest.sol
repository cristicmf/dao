import "../../src/collections/AddressSet.slb";

// TODO sol-unit format

contract AddressSetDb {

    using AddressSet for AddressSet.Set;

    AddressSet.Set _set;

    function addAddress(address addr) returns (bool had) {
        return _set.insert(addr);
    }

    function removeAddress(address addr) returns (bool removed) {
        return _set.remove(addr);
    }

    function removeAllAddresses() returns (uint numRemoved) {
        return _set.removeAll();
    }

    function hasAddress(address addr) constant returns (bool has) {
        return _set.hasValue(addr);
    }

    function getAddressFromIndex(uint index) constant returns (address addr, bool has) {
        return _set.valueFromIndex(index);
    }

    function numAddresses() constant returns (uint setSize) {
        return _set.size();
    }
}


contract AddressSetTest {

    address constant TEST_ADDRESS = 0x12345;
    address constant TEST_ADDRESS_2 = 0xABCDEF;
    address constant TEST_ADDRESS_3 = 0xC0FFEE;

    function testInsert() returns (bool has, bool firstIsCorrect) {
        AddressSetDb asdb = new AddressSetDb();
        asdb.addAddress(TEST_ADDRESS);
        has = asdb.hasAddress(TEST_ADDRESS);
        var (a, e) = asdb.getAddressFromIndex(0);
        firstIsCorrect = e && a == TEST_ADDRESS;
        return;
    }

    function testRemoveAddress() returns (bool removed, bool firstIsCorrect, bool sizeIsCorrect) {
        AddressSetDb asdb = new AddressSetDb();
        asdb.addAddress(TEST_ADDRESS);
        asdb.removeAddress(TEST_ADDRESS);
        removed = !asdb.hasAddress(TEST_ADDRESS);
        var (a, e) = asdb.getAddressFromIndex(0);
        firstIsCorrect = !e && a == 0;
        sizeIsCorrect = asdb.numAddresses() == 0;
    }

    function testAddTwoAddresses() returns (bool hasFirst, bool hasSecond, bool firstIsCorrect, bool secondIsCorrect, bool sizeIsCorrect) {
        AddressSetDb asdb = new AddressSetDb();
        asdb.addAddress(TEST_ADDRESS);
        asdb.addAddress(TEST_ADDRESS_2);
        hasFirst = asdb.hasAddress(TEST_ADDRESS);
        hasSecond = asdb.hasAddress(TEST_ADDRESS_2);
        var (a, e) = asdb.getAddressFromIndex(0);
        firstIsCorrect = e && a == TEST_ADDRESS;
        (a, e) = asdb.getAddressFromIndex(1);
        secondIsCorrect = e && a == TEST_ADDRESS_2;

        sizeIsCorrect = asdb.numAddresses() == 2;
    }

    function testAddTwoAddressesRemoveLast() returns (bool hasFirst, bool secondRemoved, bool firstIsCorrect,
                bool secondIsCorrect, bool sizeIsCorrect) {
        AddressSetDb asdb = new AddressSetDb();
        asdb.addAddress(TEST_ADDRESS);
        asdb.addAddress(TEST_ADDRESS_2);
        asdb.removeAddress(TEST_ADDRESS_2);

        hasFirst = asdb.hasAddress(TEST_ADDRESS);
        secondRemoved = !asdb.hasAddress(TEST_ADDRESS_2);

        var (a, e) = asdb.getAddressFromIndex(0);
        firstIsCorrect = e && a == TEST_ADDRESS;
        (a, e) = asdb.getAddressFromIndex(1);
        secondIsCorrect = !e && a == 0;
        sizeIsCorrect = asdb.numAddresses() == 1;
    }

    function testAddTwoAddressesRemoveFirst() returns (bool firstRemoved, bool hasSecond, bool firstIsCorrect,
                bool secondIsCorrect, bool sizeIsCorrect) {
        AddressSetDb asdb = new AddressSetDb();
        asdb.addAddress(TEST_ADDRESS);
        asdb.addAddress(TEST_ADDRESS_2);
        asdb.removeAddress(TEST_ADDRESS);

        firstRemoved = !asdb.hasAddress(TEST_ADDRESS);
        hasSecond = asdb.hasAddress(TEST_ADDRESS_2);

        var (a, e) = asdb.getAddressFromIndex(0);
        firstIsCorrect = e && a == TEST_ADDRESS_2;
        (a, e) = asdb.getAddressFromIndex(1);
        secondIsCorrect = !e && a == 0;
        sizeIsCorrect = asdb.numAddresses() == 1;
    }

    function testAddThreeAddressesRemoveMiddle() returns (bool hasFirst, bool secondRemoved, bool hasThird,
                bool firstIsCorrect, bool secondIsCorrect, bool sizeIsCorrect) {
        AddressSetDb asdb = new AddressSetDb();
        asdb.addAddress(TEST_ADDRESS);
        asdb.addAddress(TEST_ADDRESS_2);
        asdb.addAddress(TEST_ADDRESS_3);
        asdb.removeAddress(TEST_ADDRESS_2);

        hasFirst = asdb.hasAddress(TEST_ADDRESS);
        secondRemoved = !asdb.hasAddress(TEST_ADDRESS_2);
        hasThird = asdb.hasAddress(TEST_ADDRESS_3);

        var (a, e) = asdb.getAddressFromIndex(0);
        firstIsCorrect = e && a == TEST_ADDRESS;
        (a, e) = asdb.getAddressFromIndex(1);
        secondIsCorrect = e && a == TEST_ADDRESS_3;
        sizeIsCorrect = asdb.numAddresses() == 2;
    }

    function testRemoveAllAddresses() returns (bool firstRemoved, bool secondRemoved, bool thirdRemoved,
                bool sizeIsNil) {
        AddressSetDb asdb = new AddressSetDb();
        asdb.addAddress(TEST_ADDRESS);
        asdb.addAddress(TEST_ADDRESS_2);
        asdb.addAddress(TEST_ADDRESS_3);
        asdb.removeAllAddresses();

        firstRemoved = !asdb.hasAddress(TEST_ADDRESS);
        secondRemoved = !asdb.hasAddress(TEST_ADDRESS_2);
        thirdRemoved = !asdb.hasAddress(TEST_ADDRESS_3);

        sizeIsNil = asdb.numAddresses() == 0;
    }

}