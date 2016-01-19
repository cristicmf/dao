/// @title PropertySet
/// @author Andreas Olofsson (andreas1980@gmail.com)
/// @dev PropertySet is a set backed by an iterable map with (bytes32, bool) entries.
/// O(1) insert, find, and remove.
/// Stores a boolean, and an array index (uint) for each element, in addition to the bytes32.
/// This is for easy lookup, and for making iteration possible.
/// Order of insertion is not preserved.
library PropertySet {

    // Less annoying to use a boolean then having to worry about array indices etc.
    struct Element {
        uint _valIndex;
        bool _exists;
    }

    struct Set
    {
        mapping(bytes32 => Element) _data;
        bytes32[] _values;
    }

    /// @notice PropertySet.insert(set, bytes32) to add a value to the set.
    /// @dev Add values to the set.
    /// @param set (PropertySet.Set) storage reference to the set.
    /// @param val (bytes32) the value
    /// @return added (bool) true if the bytes32 was added, false if not (meaning the value already exists).
    function insert(Set storage set, bytes32 val) returns (bool added)
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

    /// @notice PropertySet.remove(set, bytes32) to remove a value from the set.
    /// @dev Remove a value from the set.
    /// @param set (PropertySet.Set) storage reference to the set.
    /// @param val (bytes32) the value
    /// @return removed (bool) true if the value was removed, false if not (meaning the value wasn't found).
    function remove(Set storage set, bytes32 val) returns (bool removed)
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

    /// @notice PropertySet.removeAll(set) to remove all values from the set. NOTE: this might fail for large sets due to gas issues.
    /// @dev Remove all values from the set.
    /// @param set (PropertySet.Set) storage reference to the set.
    /// @return numRemoved (uint) number of elements removed.
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

    /// @notice PropertySet.hasValue(set, bytes32) to check if a value is contained in the set.
    /// @dev Check if a value exists.
    /// @param set (PropertySet.Set) storage reference to the set.
    /// @param val (bytes32) the value
    /// @return has (bool) true if the bytes32 was found, false otherwise
    function hasValue(Set storage set, bytes32 val) constant returns (bool has){
        return set._data[val]._exists;
    }

    /// @notice PropertySet.valueIndex(set, bytes32) to get the values index in the backing array.
    /// @dev Get values index in backing array.
    /// @param set (PropertySet.Set) storage reference to the set.
    /// @param val (bytes32) the value
    /// @return index (uint) the index
    /// @return exists (bool) true if the element exists, false otherwise. Used because of index=0 ambiguity.
    function valueIndex(Set storage set, bytes32 val) constant returns (uint index, bool exists){
        var elem = set._data[val];
        if(!elem._exists){
            return;
        }
        index = elem._valIndex;
        exists = true;
        return;
    }

    /// @notice PropertySet.valueFromIndex(set, bytes32) to get a value from backing array index. Useful when iterating.
    /// @dev Get value from index in backing array.
    /// @param set (PropertySet.Set) storage reference to the set.
    /// @param index (uint) the bytes32
    /// @return index (uint) the index
    /// @return exists (bool) true if the element exists, false otherwise. Used because of index=0 ambiguity.
    function valueFromIndex(Set storage set, uint index) constant returns (bytes32 value, bool exists){
        if(index >= set._values.length){
            return;
        }
        value = set._values[index];
        exists = true;
        return;
    }

    /// @notice PropertySet.size(set) to get the size of the set.
    /// @dev Get size of set.
    /// @param set (PropertySet.Set) storage reference to the set.
    /// @return size (uint) the size
    function size(Set storage set) constant returns (uint size){
        return set._values.length;
    }

}

/// @title AddressToPropertiesMultiMap
/// @author Andreas Olofsson (andreas1980@gmail.com)
/// @dev AddressToPropertiesMultiMap is a an iterable map with (address, PropertySet.Set) entries.
/// O(1) insert, find, and remove.
/// The size of the map is defined as the total number of key-value pairs.
/// Order of insertion is not preserved.
library AddressToPropertiesMultiMap {

    using PropertySet for PropertySet.Set;

    // Less annoying to use a boolean then having to worry about array indices etc.
    struct Element {
        uint _keyIndex;
        PropertySet.Set _set;
    }

    struct Map
    {
        mapping(address => Element) _data;
        address[] _keys;
        uint _size;
    }

    /// @notice AddressToPropertiesMultiMap.insert(map, key, value) to insert a (key,value) pair.
    /// @dev Insert new (key,value) pairs.
    /// @param map (AddressToPropertiesMultiMap.Map) storage reference to the multimap.
    /// @param key (address) the key
    /// @param value (bytes32) the value (property)
    /// @return added (bool) true if the pair was added, false if not (meaning the pair already exists).
    function insert(Map storage map, address key, bytes32 value) returns (bool added)
    {
        var elem = map._data[key];
        var vSet = elem._set;

        // Add
        added = vSet.insert(value);
        // If value already exists, break.
        if(!added){
            return;
        }
        // If the key did not have any mappings before, add it.
        if(vSet._values.length == 1){
            var keyIndex = map._keys.length++;
            map._keys[keyIndex] = key;
        }
        map._size++;
        return;
    }

    /// @notice AddressToPropertiesMultiMap.remove(map, key, value) to remove a (key,value) pair.
    /// @dev Remove (key,value) pairs.
    /// @param map (AddressToPropertiesMultiMap.Map) storage reference to the multimap.
    /// @param key (address) the key
    /// @param value (bytes32) the value (property)
    /// @return added (bool) true if the pair was removed, false if not (meaning the pair could not be found).
    function remove(Map storage map, address key, bytes32 value) returns (bool removed)
    {
        var elem = map._data[key];
        var vSet = elem._set;
        // Remove
        removed = vSet.remove(value);
        // If value was not found for the given key, break.
        if(!removed){
            return false;
        }
        // If this removes the last mapping with 'key' in it, remove the key entirely.
        if(vSet._values.length == 0){
            var keyIndex = elem._keyIndex;
            delete map._data[key];
            var len = map._keys.length;
            if(keyIndex != len - 1){
                var swap = map._keys[len - 1];
                map._keys[keyIndex] = swap;
                map._data[swap]._keyIndex = keyIndex;
            }
            map._keys.length--;
        }
        map._size--;
        return;
    }

    /// @notice AddressToPropertiesMultiMap.removeKey(map, key) to remove all mappings from a given key.
    /// @dev Remove all mappings from a given key.
    /// @param map (AddressToPropertiesMultiMap.Map) storage reference to the multimap.
    /// @param key (address) the key.
    /// @return removed (uint) number of mappings that was removed.
    function removeKey(Map storage map, address key) returns (uint removed)
    {
        var elem = map._data[key];
        var vSet = elem._set;

        // Remove
        removed = vSet.removeAll();

        // If key had no values, break.
        if(removed == 0){
            return;
        }

        var keyIndex = elem._keyIndex;
        delete map._data[key];
        var len = map._keys.length;
        if(keyIndex != len - 1){
            var swap = map._keys[len - 1];
            map._keys[keyIndex] = swap;
            map._data[swap]._keyIndex = keyIndex;
        }
        map._keys.length--;

        map._size -= removed;
        return;
    }

    /// @notice AddressToPropertiesMultiMap.removeAll(map) to remove all mappings.
    /// @dev Remove all mappings.
    /// @param map (AddressToPropertiesMultiMap.Map) storage reference to the multimap.
    /// @return pairsRemoved (uint) number of mappings that was removed.
    function removeAll(Map storage map) returns (uint numRemoved){
        var l = map._keys.length;
        if(l == 0){
            return 0;
        }

        for(uint i = 0; i < l; i++){
            var key = map._keys[i];
            map._data[key]._set.removeAll();
            delete map._data[key];
        }

        delete map._keys;
        map._size = 0;
        return l;
    }

    /// @notice AddressToPropertiesMultiMap.hasKey(map, key) to check if a key exists.
    /// @dev Check if a key exists.
    /// @param map (AddressToPropertiesMultiMap.Map) storage reference to the multimap.
    /// @param key (address) the key.
    /// @return has (bool) true if the key was found, false otherwise.
    function hasKey(Map storage map, address key) constant returns (bool has){
        return map._data[key]._set._values.length != 0;
    }

    /// @notice AddressToPropertiesMultiMap.hasMapping(map, key) to check if a (key, value) pair exists.
    /// @dev Check if a (key, value) pair exists.
    /// @param map (AddressToPropertiesMultiMap.Map) storage reference to the multimap.
    /// @param key (address) the key.
    /// @param value (bytes32) the value.
    /// @return has (bool) true if the pair was found, false otherwise.
    function hasMapping(Map storage map, address key, bytes32 value) constant returns (bool has){
        return map._data[key]._set.hasValue(value);
    }

    /// @notice AddressToPropertiesMultiMap.keyIndex(map, key) to get the index of a given key.
    /// @dev Get the index of a given key.
    /// @param map (AddressToPropertiesMultiMap.Map) storage reference to the multimap.
    /// @param key (address) the key.
    /// @return index (uint) index of the key.
    /// @return exists (bool) true if the key exists, false if not (needed to resolve index=0 ambiguity).
    function keyIndex(Map storage map, address key) constant returns (uint index, bool exists){
        var elem = map._data[key];
        if(elem._set._values.length == 0){
            return;
        }
        index = elem._keyIndex;
        exists = true;
        return;
    }

    /// @notice AddressToPropertiesMultiMap.keyFromIndex(map, index) to get a key based on its index.
    /// @dev Get a key based on its index.
    /// @param map (AddressToPropertiesMultiMap.Map) storage reference to the multimap.
    /// @param index (uint) the index.
    /// @return key (address) The key.
    /// @return exists (bool) true if the key exists, false if not (needed to resolve index=0 ambiguity).
    function keyFromIndex(Map storage map, uint index) constant returns (address key, bool exists){
        if(index >= map._keys.length){
            return;
        }
        key = map._keys[index];
        exists = true;
        return;
    }

    /// @notice AddressToPropertiesMultiMap.numKeyMappings(map, key) to get the number of values mapped to a key.
    /// @dev Get the number of values mapped to a key.
    /// @param map (AddressToPropertiesMultiMap.Map) storage reference to the multimap.
    /// @param key (address) the key.
    /// @return numKeys (uint) The number of values.
    function numKeyMappings(Map storage map, address key) constant returns (uint numValues){
        return map._data[key]._set._values.length;
    }

    /// @notice AddressToPropertiesMultiMap.valueFromKeyAndIndex(map, key, index) to get a value by key and index.
    /// @dev Get value from key and index.
    /// @param map (AddressToPropertiesMultiMap.Map) storage reference to the multimap.
    /// @param key (address) the key.
    /// @param index (uint) the index.
    /// @return value (bytes32) the value.
    /// @return value (exists) true if a value with the given index exists.
    function valueFromKeyAndIndex(Map storage map, address key, uint index) constant returns (bytes32 value, bool exists){
        return map._data[key]._set.valueFromIndex(index);
    }

    /// @notice AddressToPropertiesMultiMap.size(map) to get the size of the map (total number of mappings).
    /// @dev Get the size of the map (total number of mappings).
    /// @param map (AddressToPropertiesMultiMap.Map) storage reference to the multimap.
    /// @return size (uint) The size.
    function size(Map storage map) constant returns (uint size){
        return map._size;
    }

    /// @notice AddressToPropertiesMultiMap.numKeys(map) to get the number of keys in the map.
    /// @dev Get the number of keys.
    /// @param map (AddressToPropertiesMultiMap.Map) storage reference to the multimap.
    /// @return numKeys (uint) The number of keys.
    function numKeys(Map storage map) constant returns (uint numKeys){
        return map._keys.length;
    }

}

// OPTIMIZED
// addPropertyToAddress("0xdeadbea7", "haha"): 127792
// propertyFromAddressAndIndex("0xdeadbea7", 0): 1581
contract AddressToPropertiesDb {

    using AddressToPropertiesMultiMap for AddressToPropertiesMultiMap.Map;

    AddressToPropertiesMultiMap.Map _map;

    function addPropertyToAddress(address addr, bytes32 prop) returns (bool had) {
        return _map.insert(addr, prop);
    }

    function propertyFromAddressAndIndex(address addr, uint idx) constant returns (bytes32 prop, bool exists){
        return _map.valueFromKeyAndIndex(addr, idx);
    }

}

// OPTIMIZED
// addPropertyToAddress("0xdeadbea7", "haha"): 126673
// propertyFromAddressAndIndex("0xdeadbea7", 0): 597
contract AddressToPropertiesDbInline {

    using AddressToPropertiesMultiMap for AddressToPropertiesMultiMap.Map;

    AddressToPropertiesMultiMap.Map _map;

    function addPropertyToAddress(address key, bytes32 value) returns (bool had) {
        var elem = _map._data[key];
        var vSet = elem._set;

        // Add
        var added = _insertIntoSet(vSet, value);
        // If value already exists, break.
        if(!added){
            return;
        }
        // If the key did not have any mappings before, add it.
        if(vSet._values.length == 1){
            var keyIndex = _map._keys.length++;
            _map._keys[keyIndex] = key;
        }
        _map._size++;
        return;
    }

    function _insertIntoSet(PropertySet.Set storage set, bytes32 val) internal returns (bool added) {
        if (set._data[val]._exists){
            return false;
        } else {
            var valIndex = set._values.length++;
            set._data[val] = PropertySet.Element(valIndex, true);
            set._values[valIndex] = val;
            return true;
        }
    }

    function propertyFromAddressAndIndex(address addr, uint idx) constant returns (bytes32 prop, bool exists){
        var vSet = _map._data[key]._set;
        if(index >= vSet._values.length){
            return;
        }
        value = vSet._values[index];
        exists = true;
        return;
    }
}