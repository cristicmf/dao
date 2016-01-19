// See AddressSet.slb and AddressSetDb.sol for info and comments.

// Solidity version: 0.2.0-b158e48c/.-Emscripten/clang/int linked to libethereum-1.1.1-8138fe14/.-Emscripten/clang/int

// UNOPTIMIZED
// deployment: 562545
// OPTIMIZED
// deployment: 320629
library AddressSet {

    struct Element {
        uint _valIndex;
        bool _exists;
    }

    struct Set
    {
        mapping(address => Element) _data;
        address[] _values;
    }

    function insert(Set storage set, address val) returns (bool added)
    {
        if (set._data[val]._exists){
            return false;
        } else {
            var valIndex = set._values.length++;
            set._data[val] = Element(valIndex, true);
            set._values[valIndex] = val;
            return true;
        }
    }

    function remove(Set storage set, address val) returns (bool removed)
    {
        var elem = set._data[val];
        if (!elem._exists){
            return false;
        }
        var valIndex = elem._valIndex;
        delete set._data[val];
        var len = set._values.length;
        if(valIndex != len - 1){
            var swap = set._values[len - 1];
            set._values[valIndex] = swap;
            set._data[swap]._valIndex = valIndex;
        }
        set._values.length--;
        return true;
    }

    function removeAll(Set storage set) returns (uint numRemoved){
        var l = set._values.length;
        if(l == 0){
            return 0;
        }
        for(uint i = 0; i < l; i++){
            delete set._data[set._values[i]];
        }
        delete set._values;
        return l;
    }

    function hasValue(Set storage set, address val) constant returns (bool has){
        return set._data[val]._exists;
    }

    function valueIndex(Set storage set, address val) constant returns (uint index, bool exists){
        var elem = set._data[val];
        if(!elem._exists){
            return;
        }
        index = elem._valIndex;
        exists = true;
        return;
    }

    function valueFromIndex(Set storage set, uint index) constant returns (address value, bool exists){
        if(index >= set._values.length){
            return;
        }
        value = set._values[index];
        exists = true;
        return;
    }

    function size(Set storage set) constant returns (uint size){
        return set._values.length;
    }

}


// UNOPTIMIZED
// deployment: 413235
// addAddress(0xdeadbea7): 66870
// removeAddress(0xdeadbea7): 21777 (address existed)
// removeAllAddresses(): 52875 (3 addresses)
// hasAddress(0xdeadbea7): 1056 (had)
// getAddressFromIndex(0): 1175 (had)
// getAddressKeyIndex(0xdeadbea7): 1281 (had)
// numAddresses(): 805 (1)
//
// OPTIMIZED
// deployment: 287423
// addAddress(0xdeadbea7): 66581
// removeAddress(0xdeadbea7): 21512 (address existed)
// removeAllAddresses(): 52469 (3 addresses)
// hasAddress(0xdeadbea7): 883 (had)
// getAddressFromIndex(0): 1068 (had)
// getAddressKeyIndex(0xdeadbea7): 1091 (had)
// numAddresses(): 679 (1)
contract AddressSetDbLib {

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

    function getAddressKeyIndex(address addr) constant returns (uint index, bool exists) {
        return _set.valueIndex(addr);
    }

    function numAddresses() constant returns (uint setSize) {
        return _set.size();
    }
}

// UNOPTIMIZED
// deployment: 558709
// addAddress(0xdeadbea7): 66397
// removeAddress(0xdeadbea7): 21326 (address existed)
// removeAllAddresses(): 52411 (3 addresses)
// hasAddress(0xdeadbea7): 546 (had)
// getAddressFromIndex(0): 605 (had)
// getAddressKeyIndex(0xdeadbea7): 640 (had)
// numAddresses(): 284 (1)
//
// OPTIMIZED
// deployment: 329683
// addAddress(0xdeadbea7): 66166
// removeAddress(0xdeadbea7): 21099 (address existed)
// removeAllAddresses(): 51947 (3 addresses)
// hasAddress(0xdeadbea7): 460 (had)
// getAddressFromIndex(0): 550 (had)
// getAddressKeyIndex(0xdeadbea7): 552 (had)
// numAddresses(): 217 (1)
contract AddressSetDbInline {

    using AddressSet for AddressSet.Set;

    AddressSet.Set _set;

    function addAddress(address val) returns (bool had) {
        if (_set._data[val]._exists){
            return false;
        } else {
            var valIndex = _set._values.length++;
            _set._data[val] = AddressSet.Element(valIndex, true);
            _set._values[valIndex] = val;
            return true;
        }
    }

    function removeAddress(address val) returns (bool removed) {
        var elem = _set._data[val];
        if (!elem._exists){
            return false;
        }
        var valIndex = elem._valIndex;
        delete _set._data[val];
        var len = _set._values.length;
        if(valIndex != len - 1){
            var swap = _set._values[len - 1];
            _set._values[valIndex] = swap;
            _set._data[swap]._valIndex = valIndex;
        }
        _set._values.length--;
        return true;
    }

    function removeAllAddresses() returns (uint numRemoved) {
        var l = _set._values.length;
        if(l == 0){
            return 0;
        }
        for(uint i = 0; i < l; i++){
            delete _set._data[_set._values[i]];
        }
        delete _set._values;
        return l;
    }

    function hasAddress(address val) constant returns (bool has) {
        return _set._data[val]._exists;
    }

    function getAddressFromIndex(uint index) constant returns (address value, bool has) {
        if(index >= _set._values.length){
            return;
        }
        value = _set._values[index];
        has = true;
        return;
    }

    function getAddressKeyIndex(address val) constant returns (uint index, bool exists) {
        var elem = _set._data[val];
        if(!elem._exists){
            return;
        }
        index = elem._valIndex;
        exists = true;
        return;
    }

    function numAddresses() constant returns (uint setSize) {
        return _set._values.length;
    }
}