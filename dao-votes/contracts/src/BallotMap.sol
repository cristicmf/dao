contract BallotMap {

    struct Element {
        uint _keyIndex;
        uint8 value;
    }

    struct Map
    {
        mapping(address => Element) _data;
        address[] _keys;
    }

    Map _map;

    function _insert(address key, uint8 value) internal returns (bool added) {
        _map._data[key] = Element(_map._keys.push(key) - 1, value);
        return true;
    }

    function _remove(address key) internal returns (uint8 value, bool removed) {
        var elem = _map._data[key];
        value = elem.value;
        var exists = value != 0;
        if (!exists)
            return;
        var keyIndex = elem._keyIndex;

        delete _map._data[key];
        var len = _map._keys.length;
        if (keyIndex != len - 1) {
            var swap = _map._keys[len - 1];
            _map._keys[keyIndex] = swap;
            _map._data[swap]._keyIndex = keyIndex;
        }
        _map._keys.length--;
        removed = true;
    }

    function ballotFromIndex(uint index) constant returns (address key, uint8 value, bool exists) {
        if (index >= _map._keys.length)
            return;
        key = _map._keys[index];
        value = _map._data[key].value;
        exists = true;
    }

}