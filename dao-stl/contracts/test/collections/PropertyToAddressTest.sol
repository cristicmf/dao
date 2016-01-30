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

    function testInsert() returns (bool has, bool firstIsCorrect, bool firstIndexIsCorrect, bool sizeIsCorrect) {
        PropertyToAddressDb padb = new PropertyToAddressDb();
        padb.insert(TEST_BYTES32, TEST_ADDRESS);
        has = padb.hasKey(TEST_BYTES32);
        var (b, e) = padb.keyFromIndex(0);
        firstIndexIsCorrect = e && b == TEST_BYTES32;
        firstIsCorrect = padb.get(TEST_BYTES32) == TEST_ADDRESS;
        sizeIsCorrect = padb.size() == 1;
        return;
    }

    function testOverwriteSuccess() returns (bool oldCorrect, bool addedCorrect, bool valCorrect, bool sizeIsCorrect) {
        PropertyToAddressDb padb = new PropertyToAddressDb();
        padb.insert(TEST_BYTES32, TEST_ADDRESS);
        var (old, added) = padb.insert(TEST_BYTES32, TEST_ADDRESS_2, true);
        oldCorrect = old == TEST_ADDRESS;
        addedCorrect = added;
        valCorrect = padb.get(TEST_BYTES32) == TEST_ADDRESS_2;
        sizeIsCorrect = padb.size() == 1;
    }

    function testOverwriteFail() returns (bool oldCorrect, bool addedCorrect, bool valCorrect, bool sizeIsCorrect) {
        PropertyToAddressDb padb = new PropertyToAddressDb();
        padb.insert(TEST_BYTES32, TEST_ADDRESS);
        var (old, added) = padb.insert(TEST_BYTES32, TEST_ADDRESS_2, false);
        oldCorrect = old == 0;
        addedCorrect = !added;
        valCorrect = padb.get(TEST_BYTES32) == TEST_ADDRESS;
        sizeIsCorrect = padb.size() == 1;
    }

    function testEntryFromIndex() returns (bool keyCorrect, bool valueCorrect, bool existsCorrect) {
        PropertyToAddressDb padb = new PropertyToAddressDb();
        padb.insert(TEST_BYTES32, TEST_ADDRESS);
        var (k, v, e) = padb.entryFromIndex(0);
        keyCorrect = k == TEST_BYTES32;
        valueCorrect = v == TEST_ADDRESS;
        existsCorrect = e;
        return;
    }

    function testEntryFromIndexFail() returns (bool keyCorrect, bool valueCorrect, bool existsCorrect) {
        PropertyToAddressDb padb = new PropertyToAddressDb();
        var (k, v, e) = padb.entryFromIndex(0);
        keyCorrect = k == 0;
        valueCorrect = v == 0;
        existsCorrect = !e;
        return;
    }

    function testRemove() returns (bool removed, bool firstIsCorrect, bool sizeIsCorrect) {
        PropertyToAddressDb padb = new PropertyToAddressDb();
        padb.insert(TEST_BYTES32, TEST_ADDRESS);
        padb.remove(TEST_BYTES32);
        removed = !padb.hasKey(TEST_BYTES32);
        var (b, e) = padb.keyFromIndex(0);
        firstIsCorrect = !e && b == 0;
        sizeIsCorrect = padb.size() == 0;
    }

    function testAddTwo() returns (bool hasFirst, bool hasSecond, bool firstIndexIsCorrect,
                bool secondIndexIsCorrect, bool firstIsCorrect, bool secondIsCorrect, bool sizeIsCorrect) {
        PropertyToAddressDb padb = new PropertyToAddressDb();
        padb.insert(TEST_BYTES32, TEST_ADDRESS);
        padb.insert(TEST_BYTES32_2, TEST_ADDRESS_2);
        hasFirst = padb.hasKey(TEST_BYTES32);
        hasSecond = padb.hasKey(TEST_BYTES32_2);
        var (b, e) = padb.keyFromIndex(0);
        firstIndexIsCorrect = e && b == TEST_BYTES32;
        firstIsCorrect = padb.get(TEST_BYTES32) == TEST_ADDRESS;
        (b, e) = padb.keyFromIndex(1);
        secondIndexIsCorrect = e && b == TEST_BYTES32_2;
        secondIsCorrect = padb.get(TEST_BYTES32_2) == TEST_ADDRESS_2;
        sizeIsCorrect = padb.size() == 2;
    }

    function testAddTwoRemoveLast() returns (bool hasFirst, bool secondRemoved, bool firstIndexIsCorrect,
                bool secondIndexIsCorrect, bool firstIsCorrect, bool secondIsCorrect, bool sizeIsCorrect) {
        PropertyToAddressDb padb = new PropertyToAddressDb();
        padb.insert(TEST_BYTES32, TEST_ADDRESS);
        padb.insert(TEST_BYTES32_2, TEST_ADDRESS_2);
        padb.remove(TEST_BYTES32_2);

        hasFirst = padb.hasKey(TEST_BYTES32);
        secondRemoved = !padb.hasKey(TEST_BYTES32_2);

        var (b, e) = padb.keyFromIndex(0);
        firstIndexIsCorrect = e && b == TEST_BYTES32;
        firstIsCorrect = padb.get(TEST_BYTES32) == TEST_ADDRESS;
        (b, e) = padb.keyFromIndex(1);
        secondIndexIsCorrect = !e && b == 0;
        secondIsCorrect = padb.get(TEST_BYTES32_2) == 0;

        sizeIsCorrect = padb.size() == 1;
    }

    function testAddTwoRemoveFirst() returns (bool firstRemoved, bool hasSecond, bool firstIndexIsCorrect,
                bool secondIndexIsCorrect, bool firstIsCorrect, bool secondIsCorrect, bool sizeIsCorrect) {
                    PropertyToAddressDb padb = new PropertyToAddressDb();
        padb.insert(TEST_BYTES32, TEST_ADDRESS);
        padb.insert(TEST_BYTES32_2, TEST_ADDRESS_2);
        padb.remove(TEST_BYTES32);

        firstRemoved = !padb.hasKey(TEST_BYTES32);
        hasSecond = padb.hasKey(TEST_BYTES32_2);

        var (b, e) = padb.keyFromIndex(0);
        firstIndexIsCorrect = e && b == TEST_BYTES32_2;
        firstIsCorrect = padb.get(TEST_BYTES32) == 0;
        (b, e) = padb.keyFromIndex(1);
        secondIndexIsCorrect = !e && b == 0;
        secondIsCorrect = padb.get(TEST_BYTES32_2) == TEST_ADDRESS_2;

        sizeIsCorrect = padb.size() == 1;
    }

    function testAddThreeRemoveMiddle() returns (bool hasFirst, bool secondRemoved, bool hasThird,
                bool firstIndexIsCorrect, bool secondIndexIsCorrect, bool thirdIndexIsCorrect,
                bool firstIsCorrect, bool secondIsCorrect, bool thirdIsCorrect, bool sizeIsCorrect) {
        PropertyToAddressDb padb = new PropertyToAddressDb();
        padb.insert(TEST_BYTES32, TEST_ADDRESS);
        padb.insert(TEST_BYTES32_2, TEST_ADDRESS_2);
        padb.insert(TEST_BYTES32_3, TEST_ADDRESS_3);
        padb.remove(TEST_BYTES32_2);

        hasFirst = padb.hasKey(TEST_BYTES32);
        secondRemoved = !padb.hasKey(TEST_BYTES32_2);
        hasThird = padb.hasKey(TEST_BYTES32_3);

        var (b, e) = padb.keyFromIndex(0);
        firstIndexIsCorrect = e && b == TEST_BYTES32;
        firstIsCorrect = padb.get(TEST_BYTES32) == TEST_ADDRESS;

        (b, e) = padb.keyFromIndex(1);
        secondIndexIsCorrect = e && b == TEST_BYTES32_3;
        secondIsCorrect = padb.get(TEST_BYTES32_2) == 0;

        (b, e) = padb.keyFromIndex(2);
        thirdIndexIsCorrect = !e && b == 0;
        thirdIsCorrect = padb.get(TEST_BYTES32_3) == TEST_ADDRESS_3;

        sizeIsCorrect = padb.size() == 2;
    }

}