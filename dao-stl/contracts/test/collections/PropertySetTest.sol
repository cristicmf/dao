import "../../src/collections/PropertySet.slb";
import "../../src/assertions/Asserter.sol";

contract PropertySetDb {

    using PropertySet for PropertySet.Set;

    PropertySet.Set _set;

    function addProperty(bytes32 prop) returns (bool added) {
        return _set.insert(prop);
    }

    function removeProperty(bytes32 prop) returns (bool removed) {
        return _set.remove(prop);
    }

    function hasProperty(bytes32 prop) constant returns (bool has) {
        return _set.hasValue(prop);
    }

    function propertyFromIndex(uint index) constant returns (bytes32 prop, bool has) {
        return _set.valueFromIndex(index);
    }

    function numProperties() constant returns (uint setSize) {
        return _set.size();
    }
}


contract PropertySetTest is Asserter {

    bytes32 constant TEST_PROPERTY = 0x12345;
    bytes32 constant TEST_PROPERTY_2 = 0xABCDEF;
    bytes32 constant TEST_PROPERTY_3 = 0xC0FFEE;

    function testInsert() {
        var psdb = new PropertySetDb();
        var added = psdb.addProperty(TEST_PROPERTY);
        assertTrue(added, "addProperty does not return true");
        assertTrue(psdb.hasProperty(TEST_PROPERTY), "hasProperty does not return true");
        var (a, e) = psdb.propertyFromIndex(0);
        assertTrue(e, "propertyFromIndex exist is false");
        assertBytes32Equal(a, TEST_PROPERTY, "propertyFromIndex returns the wrong address");
    }

    function testRemoveProperty() {
        var psdb = new PropertySetDb();
        psdb.addProperty(TEST_PROPERTY);
        var removed = psdb.removeProperty(TEST_PROPERTY);
        assertTrue(removed, "removeProperty does not return true");
        assertFalse(psdb.hasProperty(TEST_PROPERTY), "hasProperty does not return false");
        var (a, e) = psdb.propertyFromIndex(0);
        assertFalse(e, "propertyFromIndex exist is true");
        assertBytes32Zero(a, "propertyFromIndex returns non-zero address");
        assertUintZero(psdb.numProperties(), "size is not zero");
    }

    function testAddTwoBProperties() {
        var psdb = new PropertySetDb();
        psdb.addProperty(TEST_PROPERTY);
        var added = psdb.addProperty(TEST_PROPERTY_2);
        assertTrue(added, "addProperty does not return true for second element");
        assertTrue(psdb.hasProperty(TEST_PROPERTY), "hasProperty does not return true for first element");
        assertTrue(psdb.hasProperty(TEST_PROPERTY_2), "hasProperty does not return true for second element");
        var (a, e) = psdb.propertyFromIndex(0);
        assertTrue(e, "propertyFromIndex exist is false for first element");
        assertBytes32Equal(a, TEST_PROPERTY, "propertyFromIndex returns the wrong address for first element");
        (a, e) = psdb.propertyFromIndex(1);
        assertTrue(e, "propertyFromIndex exist is false for second element");
        assertBytes32Equal(a, TEST_PROPERTY_2, "propertyFromIndex returns the wrong address for second element");

        assertUintsEqual(psdb.numProperties(), 2, "size is not 2");
    }

    function testAddTwoPropertiesRemoveLast() {
        var psdb = new PropertySetDb();
        psdb.addProperty(TEST_PROPERTY);
        psdb.addProperty(TEST_PROPERTY_2);
        psdb.removeProperty(TEST_PROPERTY_2);

        assertTrue(psdb.hasProperty(TEST_PROPERTY), "hasProperty does not return true for first element");
        assertFalse(psdb.hasProperty(TEST_PROPERTY_2), "hasProperty does not return false for second element");

        var (a, e) = psdb.propertyFromIndex(0);
        assertTrue(e, "propertyFromIndex exist is false for first element");
        assertBytes32Equal(a, TEST_PROPERTY, "propertyFromIndex returns the wrong address for first element");
        (a, e) = psdb.propertyFromIndex(1);
        assertFalse(e, "propertyFromIndex exist is true for second element");
        assertBytes32Zero(a, "propertyFromIndex returns the wrong address for second element");

        assertUintsEqual(psdb.numProperties(), 1, "size is not 1");
    }

    function testAddTwoPropertiesRemoveFirst() {
        var psdb = new PropertySetDb();
        psdb.addProperty(TEST_PROPERTY);
        psdb.addProperty(TEST_PROPERTY_2);
        psdb.removeProperty(TEST_PROPERTY);

        assertFalse(psdb.hasProperty(TEST_PROPERTY), "hasProperty does not return false for first element");
        assertTrue(psdb.hasProperty(TEST_PROPERTY_2), "hasProperty does not return true for second element");

        var (a, e) = psdb.propertyFromIndex(0);
        assertTrue(e, "propertyFromIndex exist is false for first element");
        assertBytes32Equal(a, TEST_PROPERTY_2, "propertyFromIndex returns the wrong address for first element");
        (a, e) = psdb.propertyFromIndex(1);
        assertFalse(e, "propertyFromIndex exist is true for second element");
        assertBytes32Zero(a, "propertyFromIndex returns the wrong address for second element");

        assertUintsEqual(psdb.numProperties(), 1, "size is not 1");
    }

    function testAddThreePropertiesRemoveMiddle() {
        var psdb = new PropertySetDb();
        psdb.addProperty(TEST_PROPERTY);
        psdb.addProperty(TEST_PROPERTY_2);
        psdb.addProperty(TEST_PROPERTY_3);
        psdb.removeProperty(TEST_PROPERTY_2);

        assertTrue(psdb.hasProperty(TEST_PROPERTY), "hasProperty does not return true for first element");
        assertFalse(psdb.hasProperty(TEST_PROPERTY_2), "hasProperty does not return false for second element");
        assertTrue(psdb.hasProperty(TEST_PROPERTY_3), "hasProperty does not return true for third element");

        var (a, e) = psdb.propertyFromIndex(0);
        assertTrue(e, "propertyFromIndex exist is false for first element");
        assertBytes32Equal(a, TEST_PROPERTY, "propertyFromIndex returns the wrong address for first element");

        (a, e) = psdb.propertyFromIndex(1);
        assertTrue(e, "propertyFromIndex exist is false for second element");
        assertBytes32Equal(a, TEST_PROPERTY_3, "propertyFromIndex returns the wrong address for second element");

        (a, e) = psdb.propertyFromIndex(2);
        assertFalse(e, "propertyFromIndex exist is true for third element");
        assertBytes32Zero(a, "propertyFromIndex returns the wrong address for third element");
    }

}