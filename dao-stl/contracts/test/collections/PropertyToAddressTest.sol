import "../../src/collections/PropertyToAddressMap.slb";
import "../../src/assertions/Asserter.sol";

// TODO sol-unit format

contract PropertyToAddressDb {

    using PropertyToAddressMap for PropertyToAddressMap.Map;

    PropertyToAddressMap.Map _map;

    function insert(bytes32 key, address value) returns (address oldValue) {
        return _map.insert(key, value);
    }

    function insert(bytes32 key, address value, bool overwrite) returns (address oldValue, bool added) {
        return _map.insert(key, value, overwrite);
    }

    function get(bytes32 key) constant returns (address value){
        return _map.get(key);
    }

    function remove(bytes32 key) returns (address value, bool removed) {
        return _map.remove(key);
    }

    function hasKey(bytes32 key) constant returns (bool has) {
        return _map.hasKey(key);
    }

    function keyFromIndex(uint index) constant returns (bytes32 key, bool has) {
        return _map.keyFromIndex(index);
    }

    function entryFromIndex(uint index) constant returns (bytes32 key, address value, bool has) {
        return _map.entryFromIndex(index);
    }

    function size() constant returns (uint size) {
        return _map.size();
    }
}


contract PropertyToAddressTest is Asserter {

    address constant TEST_ADDRESS = 0x12345;
    address constant TEST_ADDRESS_2 = 0xABCDEF;
    address constant TEST_ADDRESS_3 = 0xC0FFEE;

    bytes32 constant TEST_BYTES32   = 1;
    bytes32 constant TEST_BYTES32_2 = 2;
    bytes32 constant TEST_BYTES32_3 = 3;

    function testInsert() {
        PropertyToAddressDb padb = new PropertyToAddressDb();
        var old = padb.insert(TEST_BYTES32, TEST_ADDRESS);

        assertAddressZero(old, "insert returns wrong old address");
        assertTrue(padb.hasKey(TEST_BYTES32), "hasKey does not return true");
        var (b, e) = padb.keyFromIndex(0);
        assertTrue(e, "keyFromIndex exist is false");
        assertBytes32Equal(b, TEST_BYTES32, "keyFromIndex returns the wrong address");
        assertAddressesEqual(padb.get(TEST_BYTES32), TEST_ADDRESS, "get returns the wrong address");
        assertUintsEqual(padb.size(), 1, "size is not 1");
    }

    function testOverwriteSuccess() {
        PropertyToAddressDb padb = new PropertyToAddressDb();
        padb.insert(TEST_BYTES32, TEST_ADDRESS);
        var (old, added) = padb.insert(TEST_BYTES32, TEST_ADDRESS_2, true);
        assertAddressesEqual(old, TEST_ADDRESS, "insert returns wrong old address");
        assertTrue(added, "added is not true");
        assertAddressesEqual(padb.get(TEST_BYTES32), TEST_ADDRESS_2, "get returns the wrong address");
        assertUintsEqual(padb.size(), 1, "size is not 1");
    }

    function testOverwriteFail() {
        PropertyToAddressDb padb = new PropertyToAddressDb();
        padb.insert(TEST_BYTES32, TEST_ADDRESS);
        var (old, added) = padb.insert(TEST_BYTES32, TEST_ADDRESS_2, false);
        assertAddressZero(old, "insert returns wrong old address");
        assertFalse(added, "added is true");
        assertAddressesEqual(padb.get(TEST_BYTES32), TEST_ADDRESS, "get returns the wrong address");
        assertUintsEqual(padb.size(), 1, "size is not 1");
    }

    function testEntryFromIndex() {
        PropertyToAddressDb padb = new PropertyToAddressDb();
        padb.insert(TEST_BYTES32, TEST_ADDRESS);
        var (k, v, e) = padb.entryFromIndex(0);
        assertBytes32Equal(k, TEST_BYTES32, "entryFromIndex returns the wrong key");
        assertAddressesEqual(v, TEST_ADDRESS, "entryFromIndex returns the wrong value");
        assertTrue(e, "entryFromIndex returns the wrong existence value");
    }

    function testEntryFromIndexFail() {
        PropertyToAddressDb padb = new PropertyToAddressDb();
        var (k, v, e) = padb.entryFromIndex(0);
        assertBytes32Zero(k, "entryFromIndex returns the wrong key");
        assertAddressZero(v, "entryFromIndex returns the wrong value");
        assertFalse(e, "entryFromIndex returns the wrong existence value");
    }

    function testRemove() {
        PropertyToAddressDb padb = new PropertyToAddressDb();
        padb.insert(TEST_BYTES32, TEST_ADDRESS);
        var (addr, removed) = padb.remove(TEST_BYTES32);
        assertAddressesEqual(addr, TEST_ADDRESS, "remove returns the wrong address");
        assertTrue(removed, "remove returns the wrong result");
        assertFalse(padb.hasKey(TEST_BYTES32), "hasKey returns true");
        var (b, e) = padb.keyFromIndex(0);
        assertBytes32Zero(b, "keyFromIndex returns the wrong key");
        assertFalse(e, "keyFromIndex returns the wrong existence value");
        assertUintZero(padb.size(), "size is not 0");
    }

    function testAddTwo() {
        PropertyToAddressDb padb = new PropertyToAddressDb();
        padb.insert(TEST_BYTES32, TEST_ADDRESS);
        padb.insert(TEST_BYTES32_2, TEST_ADDRESS_2);

        assertTrue(padb.hasKey(TEST_BYTES32), "hasKey does not return true for first key.");
        assertTrue(padb.hasKey(TEST_BYTES32), "hasKey does not return true for second key.");

        assertAddressesEqual(padb.get(TEST_BYTES32), TEST_ADDRESS, "get returns the wrong value for first entry.");
        assertAddressesEqual(padb.get(TEST_BYTES32_2), TEST_ADDRESS_2, "get returns the wrong value for second entry.");

        var (b, e) = padb.keyFromIndex(0);
        assertTrue(e, "keyFromIndex exist is false for first entry.");
        assertBytes32Equal(b, TEST_BYTES32, "keyFromIndex returns the wrong key for the first entry.");

        (b, e) = padb.keyFromIndex(1);
        assertTrue(e, "keyFromIndex exist is false for second entry.");
        assertBytes32Equal(b, TEST_BYTES32_2, "keyFromIndex returns the wrong key for second entry.");

        assertUintsEqual(padb.size(), 2, "size is not 2");
    }

    function testAddTwoRemoveLast() {
        PropertyToAddressDb padb = new PropertyToAddressDb();
        padb.insert(TEST_BYTES32, TEST_ADDRESS);
        padb.insert(TEST_BYTES32_2, TEST_ADDRESS_2);
        padb.remove(TEST_BYTES32_2);

        assertTrue(padb.hasKey(TEST_BYTES32), "hasKey does not return true for first key.");
        assertFalse(padb.hasKey(TEST_BYTES32_2), "hasKey does not return false for second key.");

        assertAddressesEqual(padb.get(TEST_BYTES32), TEST_ADDRESS, "get returns the wrong value for first entry.");
        assertAddressZero(padb.get(TEST_BYTES32_2), "get returns the wrong value for second entry.");

        var (b, e) = padb.keyFromIndex(0);
        assertTrue(e, "keyFromIndex exist is false for first entry.");
        assertBytes32Equal(b, TEST_BYTES32, "keyFromIndex returns the wrong key for the first entry.");
        (b, e) = padb.keyFromIndex(1);
        assertFalse(e, "keyFromIndex exist is false for second entry.");
        assertBytes32Zero(b, "keyFromIndex returns the wrong key for second entry.");

        assertUintsEqual(padb.size(), 1, "size is not 1");
    }

    function testAddTwoRemoveFirst() {
        PropertyToAddressDb padb = new PropertyToAddressDb();
        padb.insert(TEST_BYTES32, TEST_ADDRESS);
        padb.insert(TEST_BYTES32_2, TEST_ADDRESS_2);
        padb.remove(TEST_BYTES32);

        assertFalse(padb.hasKey(TEST_BYTES32), "hasKey does not return false for first key.");
        assertTrue(padb.hasKey(TEST_BYTES32_2), "hasKey does not return true for second key.");

        assertAddressZero(padb.get(TEST_BYTES32), "get returns the wrong value for first entry.");
        assertAddressesEqual(padb.get(TEST_BYTES32_2), TEST_ADDRESS_2, "get returns the wrong value for second entry.");


        var (b, e) = padb.keyFromIndex(0);
        assertTrue(e, "keyFromIndex exist is false for first entry.");
        assertBytes32Equal(b, TEST_BYTES32_2, "keyFromIndex returns the wrong key for the first entry.");
        (b, e) = padb.keyFromIndex(1);
        assertFalse(e, "keyFromIndex exist is false for second entry.");
        assertBytes32Zero(b, "keyFromIndex returns the wrong key for second entry.");

        assertUintsEqual(padb.size(), 1, "size is not 1");
    }

    function testAddThreeRemoveMiddle() {

        PropertyToAddressDb padb = new PropertyToAddressDb();
        padb.insert(TEST_BYTES32, TEST_ADDRESS);
        padb.insert(TEST_BYTES32_2, TEST_ADDRESS_2);
        padb.insert(TEST_BYTES32_3, TEST_ADDRESS_3);
        padb.remove(TEST_BYTES32_2);

        assertTrue(padb.hasKey(TEST_BYTES32), "hasKey does not return false for first key.");
        assertFalse(padb.hasKey(TEST_BYTES32_2), "hasKey does not return false for second key.");
        assertTrue(padb.hasKey(TEST_BYTES32_3), "hasKey does not return true for first key.");

        assertAddressesEqual(padb.get(TEST_BYTES32), TEST_ADDRESS, "get returns the wrong value for first entry.");
        assertAddressZero(padb.get(TEST_BYTES32_2), "get returns the wrong value for second entry.");
        assertAddressesEqual(padb.get(TEST_BYTES32_3), TEST_ADDRESS_3, "get returns the wrong value for third entry.");

        var (b, e) = padb.keyFromIndex(0);
        assertTrue(e, "keyFromIndex exist is false for first entry.");
        assertBytes32Equal(b, TEST_BYTES32, "keyFromIndex returns the wrong key for the first entry.");

        (b, e) = padb.keyFromIndex(1);
        assertTrue(e, "keyFromIndex exist is false for second entry.");
        assertBytes32Equal(b, TEST_BYTES32_3, "keyFromIndex returns the wrong key for the second entry.");

        (b, e) = padb.keyFromIndex(2);
        assertFalse(e, "keyFromIndex exist is false for third entry.");
        assertBytes32Zero(b, "keyFromIndex returns the wrong key for third entry.");

        assertUintsEqual(padb.size(), 2, "size is not 2");
    }

}