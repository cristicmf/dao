import "../../src/collections/PropertyToAddressesMultiMap.slb";

contract PropertyToAddressesDb {

    using PropertyToAddressesMultiMap for PropertyToAddressesMultiMap.Map;

    PropertyToAddressesMultiMap.Map _map;

    function addAddressToProperty(bytes32 prop, address addr) returns (bool had) {
        return _map.insert(prop, addr);
    }

    function removeAddressFromProperty(bytes32 prop, address addr) returns (bool removed) {
        return _map.remove(prop, addr);
    }

    function removeAllAddressesFromProperty(bytes32 prop) returns (uint numRemoved) {
        return _map.removeKey(prop);
    }

    function clear() returns (uint numRemoved) {
        return _map.removeAll();
    }

    function hasKey(bytes32 prop) constant returns (bool has) {
        return _map.hasKey(prop);
    }

    function propertyHasAddress(bytes32 prop, address addr) constant returns (bool has) {
        return _map.hasMapping(prop, addr);
    }

    function propertyFromIndex(uint index) constant returns (bytes32 prop, bool has) {
        return _map.keyFromIndex(index);
    }

    function numAddressesOfProperty(bytes32 prop) constant returns (uint numProps){
        return _map.numKeyMappings(prop);
    }

    function addressFromPropertyAndIndex(bytes32 prop, uint idx) constant returns (address addr, bool exists){
        return _map.valueFromKeyAndIndex(prop, idx);
    }

    function mapSize() constant returns (uint setSize) {
        return _map.size();
    }

    function numProperties() constant returns (uint setSize) {
        return _map.numKeys();
    }
}


contract PropertyToAddressesTest {

    bytes32 constant TEST_PROPERTY   = 1;
    bytes32 constant TEST_PROPERTY_2 = 2;
    bytes32 constant TEST_PROPERTY_3 = 3;
    
    address constant TEST_ADDRESS = 0x12345;
    address constant TEST_ADDRESS_2 = 0xABCDEF;
    address constant TEST_ADDRESS_3 = 0xC0FFEE;

    function testAddSinglePropertyToAddress() returns (bool has, bool firstIsCorrect, bool keyMappingsSizeCorrect,
                bool valByIndexCorrect, bool sizeIsCorrect, bool numPropertiesIsCorrect){
        PropertyToAddressesDb pasdb = new PropertyToAddressesDb();
        pasdb.addAddressToProperty(TEST_PROPERTY, TEST_ADDRESS);

        has = pasdb.propertyHasAddress(TEST_PROPERTY, TEST_ADDRESS);
        var (p, e) = pasdb.propertyFromIndex(0);
        firstIsCorrect = e && p == TEST_PROPERTY;
        keyMappingsSizeCorrect = pasdb.numAddressesOfProperty(TEST_PROPERTY) == 1;
        var (a, ae) = pasdb.addressFromPropertyAndIndex(TEST_PROPERTY, 0);
        valByIndexCorrect = ae && a == TEST_ADDRESS;
        sizeIsCorrect = pasdb.mapSize() == 1;
        numPropertiesIsCorrect = pasdb.numProperties() == 1;
        return;
    }

    function testRemovePropertyFromAddress() returns (bool removed, bool firstIsCorrect, bool keyMappingsSizeCorrect,
                    bool valByIndexCorrect, bool sizeIsCorrect, bool numPropertiesIsCorrect){
        PropertyToAddressesDb pasdb = new PropertyToAddressesDb();
        pasdb.addAddressToProperty(TEST_PROPERTY, TEST_ADDRESS);
        pasdb.removeAddressFromProperty(TEST_PROPERTY, TEST_ADDRESS);
        removed = !pasdb.propertyHasAddress(TEST_PROPERTY, TEST_ADDRESS);
        var (p, e) = pasdb.propertyFromIndex(0);
        firstIsCorrect = !e && p == 0;
        keyMappingsSizeCorrect = pasdb.numAddressesOfProperty(TEST_PROPERTY) == 0;
        var (a, ae) = pasdb.addressFromPropertyAndIndex(TEST_PROPERTY, 0);
        valByIndexCorrect = !ae && a == 0;
        sizeIsCorrect = pasdb.mapSize() == 0;
        numPropertiesIsCorrect = pasdb.numProperties() == 0;
        return;
    }

    function testAddManyPropertiesToAddress() returns (bool hasFirst, bool hasSecond, bool hasThird,
                bool keyMappingsSizeCorrect, bool firstPropCorrect, bool secondPropCorrect, bool thirdPropCorrect,
                bool sizeIsCorrect, bool numPropertiesIsCorrect){

        PropertyToAddressesDb pasdb = new PropertyToAddressesDb();

        pasdb.addAddressToProperty(TEST_PROPERTY, TEST_ADDRESS);
        pasdb.addAddressToProperty(TEST_PROPERTY, TEST_ADDRESS_2);
        pasdb.addAddressToProperty(TEST_PROPERTY, TEST_ADDRESS_3);

        hasFirst = pasdb.propertyHasAddress(TEST_PROPERTY, TEST_ADDRESS);
        hasSecond = pasdb.propertyHasAddress(TEST_PROPERTY, TEST_ADDRESS_2);
        hasThird = pasdb.propertyHasAddress(TEST_PROPERTY, TEST_ADDRESS_3);
        keyMappingsSizeCorrect = pasdb.numAddressesOfProperty(TEST_PROPERTY) == 3;
        var (a, e) = pasdb.addressFromPropertyAndIndex(TEST_PROPERTY, 0);
        firstPropCorrect = e && a == TEST_ADDRESS;
        (a, e) = pasdb.addressFromPropertyAndIndex(TEST_PROPERTY, 1);
        secondPropCorrect = e && a == TEST_ADDRESS_2;
        (a, e) = pasdb.addressFromPropertyAndIndex(TEST_PROPERTY, 2);
        thirdPropCorrect = e && a == TEST_ADDRESS_3;
        sizeIsCorrect = pasdb.mapSize() == 3;
        numPropertiesIsCorrect = pasdb.numProperties() == 1;
        return;
    }

    function testAddManyPropertiesToAddressRemoveOne() returns (bool firstRemoved, bool hasSecond, bool hasThird,
                bool keyMappingsSizeCorrect, bool firstPropCorrect, bool secondPropCorrect, bool sizeIsCorrect,
                bool numPropertiesIsCorrect){

        PropertyToAddressesDb pasdb = new PropertyToAddressesDb();

        pasdb.addAddressToProperty(TEST_PROPERTY, TEST_ADDRESS);
        pasdb.addAddressToProperty(TEST_PROPERTY, TEST_ADDRESS_2);
        pasdb.addAddressToProperty(TEST_PROPERTY, TEST_ADDRESS_3);
        pasdb.removeAddressFromProperty(TEST_PROPERTY, TEST_ADDRESS);
        firstRemoved = !pasdb.propertyHasAddress(TEST_PROPERTY, TEST_ADDRESS);
        hasSecond = pasdb.propertyHasAddress(TEST_PROPERTY, TEST_ADDRESS_2);
        hasThird = pasdb.propertyHasAddress(TEST_PROPERTY, TEST_ADDRESS_3);
        keyMappingsSizeCorrect = pasdb.numAddressesOfProperty(TEST_PROPERTY) == 2;
        var (a, e) = pasdb.addressFromPropertyAndIndex(TEST_PROPERTY, 0);
        firstPropCorrect = e && a == TEST_ADDRESS_3;
        (a, e) = pasdb.addressFromPropertyAndIndex(TEST_PROPERTY, 1);
        secondPropCorrect = e && a == TEST_ADDRESS_2;
        sizeIsCorrect = pasdb.mapSize() == 2;
        numPropertiesIsCorrect = pasdb.numProperties() == 1;
        return;
    }

    function testAddManyPropertiesToAddressRemoveAll() returns (bool firstRemoved, bool secondRemoved,
                    bool thirdRemoved, bool keyMappingsSizeCorrect, bool sizeIsCorrect, bool numPropertiesIsCorrect){

        PropertyToAddressesDb pasdb = new PropertyToAddressesDb();

        pasdb.addAddressToProperty(TEST_PROPERTY, TEST_ADDRESS);
        pasdb.addAddressToProperty(TEST_PROPERTY, TEST_ADDRESS_2);
        pasdb.addAddressToProperty(TEST_PROPERTY, TEST_ADDRESS_3);
        pasdb.removeAllAddressesFromProperty(TEST_PROPERTY);
        firstRemoved = !pasdb.propertyHasAddress(TEST_PROPERTY, TEST_ADDRESS);
        secondRemoved = !pasdb.propertyHasAddress(TEST_PROPERTY, TEST_ADDRESS_2);
        thirdRemoved = !pasdb.propertyHasAddress(TEST_PROPERTY, TEST_ADDRESS_3);
        keyMappingsSizeCorrect = pasdb.numAddressesOfProperty(TEST_PROPERTY) == 0;
        sizeIsCorrect = pasdb.mapSize() == 0;
        numPropertiesIsCorrect = pasdb.numProperties() == 0;
        return;
    }

    function testAddManyAddresses() returns (bool hasFirst, bool hasSecond, bool hasThird,
                bool firstPropCorrect, bool secondPropCorrect, bool thirdPropCorrect,
                bool sizeIsCorrect, bool numPropertiesIsCorrect){

        PropertyToAddressesDb pasdb = new PropertyToAddressesDb();

        pasdb.addAddressToProperty(TEST_PROPERTY, TEST_ADDRESS);
        pasdb.addAddressToProperty(TEST_PROPERTY_2, TEST_ADDRESS_2);
        pasdb.addAddressToProperty(TEST_PROPERTY_3, TEST_ADDRESS_3);

        hasFirst = pasdb.propertyHasAddress(TEST_PROPERTY, TEST_ADDRESS);
        hasSecond = pasdb.propertyHasAddress(TEST_PROPERTY_2, TEST_ADDRESS_2);
        hasThird = pasdb.propertyHasAddress(TEST_PROPERTY_3, TEST_ADDRESS_3);
        var (a, e) = pasdb.addressFromPropertyAndIndex(TEST_PROPERTY, 0);
        firstPropCorrect = e && a == TEST_ADDRESS;
        (a, e) = pasdb.addressFromPropertyAndIndex(TEST_PROPERTY_2, 0);
        secondPropCorrect = e && a == TEST_ADDRESS_2;
        (a, e) = pasdb.addressFromPropertyAndIndex(TEST_PROPERTY_3, 0);
        thirdPropCorrect = e && a == TEST_ADDRESS_3;
        sizeIsCorrect = pasdb.mapSize() == 3;
        numPropertiesIsCorrect = pasdb.numProperties() == 3;
        return;
    }

    function testAddManyAddressesRemoveOne() returns (bool hasFirst, bool secondRemoved, bool hasThird,
                    bool firstPropCorrect, bool secondPropCorrect, bool thirdPropCorrect,
                    bool sizeIsCorrect, bool numPropertiesIsCorrect){

        PropertyToAddressesDb pasdb = new PropertyToAddressesDb();

        pasdb.addAddressToProperty(TEST_PROPERTY, TEST_ADDRESS);
        pasdb.addAddressToProperty(TEST_PROPERTY_2, TEST_ADDRESS_2);
        pasdb.addAddressToProperty(TEST_PROPERTY_3, TEST_ADDRESS_3);
        pasdb.removeAddressFromProperty(TEST_PROPERTY_2, TEST_ADDRESS_2);
        hasFirst = pasdb.propertyHasAddress(TEST_PROPERTY, TEST_ADDRESS);
        secondRemoved = !pasdb.propertyHasAddress(TEST_PROPERTY_2, TEST_ADDRESS_2);
        hasThird = pasdb.propertyHasAddress(TEST_PROPERTY_3, TEST_ADDRESS_3);
        var (a, e) = pasdb.addressFromPropertyAndIndex(TEST_PROPERTY, 0);
        firstPropCorrect = e && a == TEST_ADDRESS;
        (a, e) = pasdb.addressFromPropertyAndIndex(TEST_PROPERTY_2, 0);
        secondPropCorrect = !e && a == 0;
        (a, e) = pasdb.addressFromPropertyAndIndex(TEST_PROPERTY_3, 0);
        thirdPropCorrect = e && a == TEST_ADDRESS_3;
        sizeIsCorrect = pasdb.mapSize() == 2;
        numPropertiesIsCorrect = pasdb.numProperties() == 2;
        return;
    }

    function testAddManyAddressesRemoveAll() returns (bool firstRemoved, bool secondRemoved, bool thirdRemoved,
                        bool firstPropCorrect, bool secondPropCorrect, bool thirdPropCorrect,
                        bool sizeIsCorrect, bool numPropertiesIsCorrect){

        PropertyToAddressesDb pasdb = new PropertyToAddressesDb();

        pasdb.addAddressToProperty(TEST_PROPERTY, TEST_ADDRESS);
        pasdb.addAddressToProperty(TEST_PROPERTY_2, TEST_ADDRESS_2);
        pasdb.addAddressToProperty(TEST_PROPERTY_3, TEST_ADDRESS_3);
        pasdb.clear();

        firstRemoved = !pasdb.propertyHasAddress(TEST_PROPERTY, TEST_ADDRESS);
        secondRemoved = !pasdb.propertyHasAddress(TEST_PROPERTY_2, TEST_ADDRESS_2);
        thirdRemoved = !pasdb.propertyHasAddress(TEST_PROPERTY_3, TEST_ADDRESS_3);
        var (a, e) = pasdb.addressFromPropertyAndIndex(TEST_PROPERTY, 0);
        firstPropCorrect = !e && a == 0;
        (a, e) = pasdb.addressFromPropertyAndIndex(TEST_PROPERTY_2, 0);
        secondPropCorrect = !e && a == 0;
        (a, e) = pasdb.addressFromPropertyAndIndex(TEST_PROPERTY_3, 0);
        thirdPropCorrect = !e && a == 0;
        sizeIsCorrect = pasdb.mapSize() == 0;
        numPropertiesIsCorrect = pasdb.numProperties() == 0;
        return;
    }

}