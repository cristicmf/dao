import "../../src/collections/PropertySet.slb";

// TODO sol-unit format

contract PropertySetDb {

    using PropertySet for PropertySet.Set;

    PropertySet.Set _set;

    function addProperty(bytes32 prop) returns (bool had) {
        return _set.insert(prop);
    }

    function removeProperty(bytes32 prop) returns (bool removed) {
        return _set.remove(prop);
    }

    function removeAllProperties() returns (uint numRemoved) {
        return _set.removeAll();
    }

    function hasProperty(bytes32 prop) constant returns (bool has) {
        return _set.hasValue(prop);
    }

    function getPropertyFromIndex(uint index) constant returns (bytes32 prop, bool has) {
        return _set.valueFromIndex(index);
    }

    function numProperties() constant returns (uint setSize) {
        return _set.size();
    }
}


contract PropertySetTest {

    bytes32 constant TEST_PROPERTY = 0x12345;
    bytes32 constant TEST_PROPERTY_2 = 0xABCDEF;
    bytes32 constant TEST_PROPERTY_3 = 0xC0FFEE;

    function testInsert() returns (bool has, bool firstIsCorrect) {
        PropertySetDb psdb = new PropertySetDb();
        psdb.addProperty(TEST_PROPERTY);
        has = psdb.hasProperty(TEST_PROPERTY);
        var (a, e) = psdb.getPropertyFromIndex(0);
        firstIsCorrect = e && a == TEST_PROPERTY;
        return;
    }

    function testRemoveProperty() returns (bool removed, bool firstIsCorrect, bool sizeIsCorrect) {
        PropertySetDb psdb = new PropertySetDb();
        psdb.addProperty(TEST_PROPERTY);
        psdb.removeProperty(TEST_PROPERTY);
        removed = !psdb.hasProperty(TEST_PROPERTY);
        var (a, e) = psdb.getPropertyFromIndex(0);
        firstIsCorrect = !e && a == 0;
        sizeIsCorrect = psdb.numProperties() == 0;
    }

    function testAddTwoProperties() returns (bool hasFirst, bool hasSecond, bool firstIsCorrect, bool secondIsCorrect, bool sizeIsCorrect) {
        PropertySetDb psdb = new PropertySetDb();
        psdb.addProperty(TEST_PROPERTY);
        psdb.addProperty(TEST_PROPERTY_2);
        hasFirst = psdb.hasProperty(TEST_PROPERTY);
        hasSecond = psdb.hasProperty(TEST_PROPERTY_2);
        var (a, e) = psdb.getPropertyFromIndex(0);
        firstIsCorrect = e && a == TEST_PROPERTY;
        (a, e) = psdb.getPropertyFromIndex(1);
        secondIsCorrect = e && a == TEST_PROPERTY_2;

        sizeIsCorrect = psdb.numProperties() == 2;
    }

    function testAddTwoPropertiesRemoveLast() returns (bool hasFirst, bool secondRemoved, bool firstIsCorrect,
                bool secondIsCorrect, bool sizeIsCorrect) {
        PropertySetDb psdb = new PropertySetDb();
        psdb.addProperty(TEST_PROPERTY);
        psdb.addProperty(TEST_PROPERTY_2);
        psdb.removeProperty(TEST_PROPERTY_2);

        hasFirst = psdb.hasProperty(TEST_PROPERTY);
        secondRemoved = !psdb.hasProperty(TEST_PROPERTY_2);

        var (a, e) = psdb.getPropertyFromIndex(0);
        firstIsCorrect = e && a == TEST_PROPERTY;
        (a, e) = psdb.getPropertyFromIndex(1);
        secondIsCorrect = !e && a == 0;
        sizeIsCorrect = psdb.numProperties() == 1;
    }

    function testAddTwoPropertiesRemoveFirst() returns (bool firstRemoved, bool hasSecond, bool firstIsCorrect,
                bool secondIsCorrect, bool sizeIsCorrect) {
        PropertySetDb psdb = new PropertySetDb();
        psdb.addProperty(TEST_PROPERTY);
        psdb.addProperty(TEST_PROPERTY_2);
        psdb.removeProperty(TEST_PROPERTY);

        firstRemoved = !psdb.hasProperty(TEST_PROPERTY);
        hasSecond = psdb.hasProperty(TEST_PROPERTY_2);

        var (a, e) = psdb.getPropertyFromIndex(0);
        firstIsCorrect = e && a == TEST_PROPERTY_2;
        (a, e) = psdb.getPropertyFromIndex(1);
        secondIsCorrect = !e && a == 0;
        sizeIsCorrect = psdb.numProperties() == 1;
    }

    function testAddThreePropertiesRemoveMiddle() returns (bool hasFirst, bool secondRemoved, bool hasThird,
                bool firstIsCorrect, bool secondIsCorrect, bool sizeIsCorrect) {
        PropertySetDb psdb = new PropertySetDb();
        psdb.addProperty(TEST_PROPERTY);
        psdb.addProperty(TEST_PROPERTY_2);
        psdb.addProperty(TEST_PROPERTY_3);
        psdb.removeProperty(TEST_PROPERTY_2);

        hasFirst = psdb.hasProperty(TEST_PROPERTY);
        secondRemoved = !psdb.hasProperty(TEST_PROPERTY_2);
        hasThird = psdb.hasProperty(TEST_PROPERTY_3);

        var (a, e) = psdb.getPropertyFromIndex(0);
        firstIsCorrect = e && a == TEST_PROPERTY;
        (a, e) = psdb.getPropertyFromIndex(1);
        secondIsCorrect = e && a == TEST_PROPERTY_3;
        sizeIsCorrect = psdb.numProperties() == 2;
    }

    function testRemoveAllProperties() returns (bool firstRemoved, bool secondRemoved, bool thirdRemoved,
                bool sizeIsNil) {
        PropertySetDb psdb = new PropertySetDb();
        psdb.addProperty(TEST_PROPERTY);
        psdb.addProperty(TEST_PROPERTY_2);
        psdb.addProperty(TEST_PROPERTY_3);
        psdb.removeAllProperties();

        firstRemoved = !psdb.hasProperty(TEST_PROPERTY);
        secondRemoved = !psdb.hasProperty(TEST_PROPERTY_2);
        thirdRemoved = !psdb.hasProperty(TEST_PROPERTY_3);

        sizeIsNil = psdb.numProperties() == 0;
    }

}