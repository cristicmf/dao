import "../../src/collections/AddressToPropertiesMultiMap.slb";

contract AddressToPropertiesDb {

    using AddressToPropertiesMultiMap for AddressToPropertiesMultiMap.Map;

    AddressToPropertiesMultiMap.Map _map;

    function addPropertyToAddress(address addr, bytes32 prop) returns (bool had) {
        return _map.insert(addr, prop);
    }

    function removePropertyFromAddress(address addr, bytes32 prop) returns (bool removed) {
        return _map.remove(addr, prop);
    }

    function removeAllPropertiesFromAddress(address addr) returns (uint numRemoved) {
        return _map.removeKey(addr);
    }

    function clear() returns (uint numRemoved) {
        return _map.removeAll();
    }

    function hasKey(address addr) constant returns (bool has) {
        return _map.hasKey(addr);
    }

    function addressHasProperty(address addr, bytes32 prop) constant returns (bool has) {
        return _map.hasMapping(addr, prop);
    }

    function addressFromIndex(uint index) constant returns (address addr, bool has) {
        return _map.keyFromIndex(index);
    }

    function numPropertiesOfAddress(address addr) constant returns (uint numProps){
        return _map.numKeyMappings(addr);
    }

    function propertyFromAddressAndIndex(address addr, uint idx) constant returns (bytes32 prop, bool exists){
        return _map.valueFromKeyAndIndex(addr, idx);
    }

    function mapSize() constant returns (uint setSize) {
        return _map.size();
    }

    function numAddresses() constant returns (uint setSize) {
        return _map.numKeys();
    }
}

contract AddressToPropertiesTest {

    address constant TEST_ADDRESS = 0x12345;
    address constant TEST_ADDRESS_2 = 0xABCDEF;
    address constant TEST_ADDRESS_3 = 0xC0FFEE;

    bytes32 constant TEST_PROPERTY   = 1;
    bytes32 constant TEST_PROPERTY_2 = 2;
    bytes32 constant TEST_PROPERTY_3 = 3;

    function testAddSinglePropertyToAddress() returns (bool has, bool firstIsCorrect, bool keyMappingsSizeCorrect,
                bool valByIndexCorrect, bool sizeIsCorrect, bool numAddressesIsCorrect){
        AddressToPropertiesDb apsdb = new AddressToPropertiesDb();
        apsdb.addPropertyToAddress(TEST_ADDRESS, TEST_PROPERTY);

        has = apsdb.addressHasProperty(TEST_ADDRESS, TEST_PROPERTY);
        var (a, e) = apsdb.addressFromIndex(0);
        firstIsCorrect = e && a == TEST_ADDRESS;
        keyMappingsSizeCorrect = apsdb.numPropertiesOfAddress(TEST_ADDRESS) == 1;
        var (p, pe) = apsdb.propertyFromAddressAndIndex(TEST_ADDRESS, 0);
        valByIndexCorrect = pe && p == TEST_PROPERTY;
        sizeIsCorrect = apsdb.mapSize() == 1;
        numAddressesIsCorrect = apsdb.numAddresses() == 1;
        return;
    }

    function testRemovePropertyFromAddress() returns (bool removed, bool firstIsCorrect, bool keyMappingsSizeCorrect,
                    bool valByIndexCorrect, bool sizeIsCorrect, bool numAddressesIsCorrect){
        AddressToPropertiesDb apsdb = new AddressToPropertiesDb();
        apsdb.addPropertyToAddress(TEST_ADDRESS, TEST_PROPERTY);
        apsdb.removePropertyFromAddress(TEST_ADDRESS, TEST_PROPERTY);
        removed = !apsdb.addressHasProperty(TEST_ADDRESS, TEST_PROPERTY);
        var (a, e) = apsdb.addressFromIndex(0);
        firstIsCorrect = !e && a == 0;
        keyMappingsSizeCorrect = apsdb.numPropertiesOfAddress(TEST_ADDRESS) == 0;
        var (p, pe) = apsdb.propertyFromAddressAndIndex(TEST_ADDRESS, 0);
        valByIndexCorrect = !pe && p == 0;
        sizeIsCorrect = apsdb.mapSize() == 0;
        numAddressesIsCorrect = apsdb.numAddresses() == 0;
        return;
    }

    function testAddManyPropertiesToAddress() returns (bool hasFirst, bool hasSecond, bool hasThird,
                bool keyMappingsSizeCorrect, bool firstPropCorrect, bool secondPropCorrect, bool thirdPropCorrect,
                bool sizeIsCorrect, bool numAddressesIsCorrect){

        AddressToPropertiesDb apsdb = new AddressToPropertiesDb();

        apsdb.addPropertyToAddress(TEST_ADDRESS, TEST_PROPERTY);
        apsdb.addPropertyToAddress(TEST_ADDRESS, TEST_PROPERTY_2);
        apsdb.addPropertyToAddress(TEST_ADDRESS, TEST_PROPERTY_3);

        hasFirst = apsdb.addressHasProperty(TEST_ADDRESS, TEST_PROPERTY);
        hasSecond = apsdb.addressHasProperty(TEST_ADDRESS, TEST_PROPERTY_2);
        hasThird = apsdb.addressHasProperty(TEST_ADDRESS, TEST_PROPERTY_3);
        keyMappingsSizeCorrect = apsdb.numPropertiesOfAddress(TEST_ADDRESS) == 3;
        var (p, e) = apsdb.propertyFromAddressAndIndex(TEST_ADDRESS, 0);
        firstPropCorrect = e && p == TEST_PROPERTY;
        (p, e) = apsdb.propertyFromAddressAndIndex(TEST_ADDRESS, 1);
        secondPropCorrect = e && p == TEST_PROPERTY_2;
        (p, e) = apsdb.propertyFromAddressAndIndex(TEST_ADDRESS, 2);
        thirdPropCorrect = e && p == TEST_PROPERTY_3;
        sizeIsCorrect = apsdb.mapSize() == 3;
        numAddressesIsCorrect = apsdb.numAddresses() == 1;
        return;
    }

    function testAddManyPropertiesToAddressRemoveOne() returns (bool firstRemoved, bool hasSecond, bool hasThird,
                bool keyMappingsSizeCorrect, bool firstPropCorrect, bool secondPropCorrect, bool sizeIsCorrect,
                bool numAddressesIsCorrect){

        AddressToPropertiesDb apsdb = new AddressToPropertiesDb();

        apsdb.addPropertyToAddress(TEST_ADDRESS, TEST_PROPERTY);
        apsdb.addPropertyToAddress(TEST_ADDRESS, TEST_PROPERTY_2);
        apsdb.addPropertyToAddress(TEST_ADDRESS, TEST_PROPERTY_3);
        apsdb.removePropertyFromAddress(TEST_ADDRESS, TEST_PROPERTY);
        firstRemoved = !apsdb.addressHasProperty(TEST_ADDRESS, TEST_PROPERTY);
        hasSecond = apsdb.addressHasProperty(TEST_ADDRESS, TEST_PROPERTY_2);
        hasThird = apsdb.addressHasProperty(TEST_ADDRESS, TEST_PROPERTY_3);
        keyMappingsSizeCorrect = apsdb.numPropertiesOfAddress(TEST_ADDRESS) == 2;
        var (p, e) = apsdb.propertyFromAddressAndIndex(TEST_ADDRESS, 0);
        firstPropCorrect = e && p == TEST_PROPERTY_3;
        (p, e) = apsdb.propertyFromAddressAndIndex(TEST_ADDRESS, 1);
        secondPropCorrect = e && p == TEST_PROPERTY_2;
        sizeIsCorrect = apsdb.mapSize() == 2;
        numAddressesIsCorrect = apsdb.numAddresses() == 1;
        return;
    }

    function testAddManyPropertiesToAddressRemoveAll() returns (bool firstRemoved, bool secondRemoved,
                    bool thirdRemoved, bool keyMappingsSizeCorrect, bool sizeIsCorrect, bool numAddressesIsCorrect){

        AddressToPropertiesDb apsdb = new AddressToPropertiesDb();

        apsdb.addPropertyToAddress(TEST_ADDRESS, TEST_PROPERTY);
        apsdb.addPropertyToAddress(TEST_ADDRESS, TEST_PROPERTY_2);
        apsdb.addPropertyToAddress(TEST_ADDRESS, TEST_PROPERTY_3);
        apsdb.removeAllPropertiesFromAddress(TEST_ADDRESS);
        firstRemoved = !apsdb.addressHasProperty(TEST_ADDRESS, TEST_PROPERTY);
        secondRemoved = !apsdb.addressHasProperty(TEST_ADDRESS, TEST_PROPERTY_2);
        thirdRemoved = !apsdb.addressHasProperty(TEST_ADDRESS, TEST_PROPERTY_3);
        keyMappingsSizeCorrect = apsdb.numPropertiesOfAddress(TEST_ADDRESS) == 0;
        sizeIsCorrect = apsdb.mapSize() == 0;
        numAddressesIsCorrect = apsdb.numAddresses() == 0;
        return;
    }

    function testAddManyAddresses() returns (bool hasFirst, bool hasSecond, bool hasThird,
                bool firstPropCorrect, bool secondPropCorrect, bool thirdPropCorrect,
                bool sizeIsCorrect, bool numAddressesIsCorrect){

        AddressToPropertiesDb apsdb = new AddressToPropertiesDb();

        apsdb.addPropertyToAddress(TEST_ADDRESS, TEST_PROPERTY);
        apsdb.addPropertyToAddress(TEST_ADDRESS_2, TEST_PROPERTY_2);
        apsdb.addPropertyToAddress(TEST_ADDRESS_3, TEST_PROPERTY_3);

        hasFirst = apsdb.addressHasProperty(TEST_ADDRESS, TEST_PROPERTY);
        hasSecond = apsdb.addressHasProperty(TEST_ADDRESS_2, TEST_PROPERTY_2);
        hasThird = apsdb.addressHasProperty(TEST_ADDRESS_3, TEST_PROPERTY_3);
        var (p, e) = apsdb.propertyFromAddressAndIndex(TEST_ADDRESS, 0);
        firstPropCorrect = e && p == TEST_PROPERTY;
        (p, e) = apsdb.propertyFromAddressAndIndex(TEST_ADDRESS_2, 0);
        secondPropCorrect = e && p == TEST_PROPERTY_2;
        (p, e) = apsdb.propertyFromAddressAndIndex(TEST_ADDRESS_3, 0);
        thirdPropCorrect = e && p == TEST_PROPERTY_3;
        sizeIsCorrect = apsdb.mapSize() == 3;
        numAddressesIsCorrect = apsdb.numAddresses() == 3;
        return;
    }

    function testAddManyAddressesRemoveOne() returns (bool hasFirst, bool secondRemoved, bool hasThird,
                    bool firstPropCorrect, bool secondPropCorrect, bool thirdPropCorrect,
                    bool sizeIsCorrect, bool numAddressesIsCorrect){

        AddressToPropertiesDb apsdb = new AddressToPropertiesDb();

        apsdb.addPropertyToAddress(TEST_ADDRESS, TEST_PROPERTY);
        apsdb.addPropertyToAddress(TEST_ADDRESS_2, TEST_PROPERTY_2);
        apsdb.addPropertyToAddress(TEST_ADDRESS_3, TEST_PROPERTY_3);
        apsdb.removePropertyFromAddress(TEST_ADDRESS_2, TEST_PROPERTY_2);
        hasFirst = apsdb.addressHasProperty(TEST_ADDRESS, TEST_PROPERTY);
        secondRemoved = !apsdb.addressHasProperty(TEST_ADDRESS_2, TEST_PROPERTY_2);
        hasThird = apsdb.addressHasProperty(TEST_ADDRESS_3, TEST_PROPERTY_3);
        var (p, e) = apsdb.propertyFromAddressAndIndex(TEST_ADDRESS, 0);
        firstPropCorrect = e && p == TEST_PROPERTY;
        (p, e) = apsdb.propertyFromAddressAndIndex(TEST_ADDRESS_2, 0);
        secondPropCorrect = !e && p == 0;
        (p, e) = apsdb.propertyFromAddressAndIndex(TEST_ADDRESS_3, 0);
        thirdPropCorrect = e && p == TEST_PROPERTY_3;
        sizeIsCorrect = apsdb.mapSize() == 2;
        numAddressesIsCorrect = apsdb.numAddresses() == 2;
        return;
    }

    function testAddManyAddressesRemoveAll() returns (bool firstRemoved, bool secondRemoved, bool thirdRemoved,
                        bool firstPropCorrect, bool secondPropCorrect, bool thirdPropCorrect,
                        bool sizeIsCorrect, bool numAddressesIsCorrect){

        AddressToPropertiesDb apsdb = new AddressToPropertiesDb();

        apsdb.addPropertyToAddress(TEST_ADDRESS, TEST_PROPERTY);
        apsdb.addPropertyToAddress(TEST_ADDRESS_2, TEST_PROPERTY_2);
        apsdb.addPropertyToAddress(TEST_ADDRESS_3, TEST_PROPERTY_3);
        apsdb.clear();

        firstRemoved = !apsdb.addressHasProperty(TEST_ADDRESS, TEST_PROPERTY);
        secondRemoved = !apsdb.addressHasProperty(TEST_ADDRESS_2, TEST_PROPERTY_2);
        thirdRemoved = !apsdb.addressHasProperty(TEST_ADDRESS_3, TEST_PROPERTY_3);
        var (p, e) = apsdb.propertyFromAddressAndIndex(TEST_ADDRESS, 0);
        firstPropCorrect = !e && p == 0;
        (p, e) = apsdb.propertyFromAddressAndIndex(TEST_ADDRESS_2, 0);
        secondPropCorrect = !e && p == 0;
        (p, e) = apsdb.propertyFromAddressAndIndex(TEST_ADDRESS_3, 0);
        thirdPropCorrect = !e && p == 0;
        sizeIsCorrect = apsdb.mapSize() == 0;
        numAddressesIsCorrect = apsdb.numAddresses() == 0;
        return;
    }

}