import "../../../dao-core/contracts/src/Database.sol";
import "../../../dao-stl/src/errors/Errors.sol";

/// @title DefaultUserDatabase
/// @author Andreas Olofsson (androlo1980@gmail.com)
/// @dev DefaultUserDatabase is an iterable map with (address, UserData) entries. Order of insertion is not preserved.
/// O(1) insert, find, and remove.
/// Stores an array index (uint) for each entry, in addition to the key and value.
/// This is for easy lookup, and for making iteration possible.
/// Order of insertion is not preserved.
contract DefaultUserDatabase is Database {

    struct Element {
        // For backing array.
        uint _keyIndex;
        // User data
        bytes32 _nickname;
        uint _timestamp;
        bytes32 _dataHash;
    }

    struct Map
    {
        mapping(address => Element) _data;
        address[] _keys;
    }

    Map _map;

    function registerUser(address addr, bytes32 value_nickname, uint value_timestamp, bytes32 value_dataHash) returns (uint16 error) {
        if (!_checkCaller())
            return ACCESS_DENIED;
        var exists = _map._data[addr]._nickname != 0;
        if (exists)
            return RESOURCE_ALREADY_EXISTS;
        else {
            var keyIndex = _map._keys.length++;
            _map._data[addr] = Element(keyIndex, value_nickname, value_timestamp, value_dataHash);
            _map._keys[keyIndex] = addr;
        }
    }

    function updateDataHash(address addr, bytes32 dataHash) returns (uint16 error) {
        if (!_checkCaller())
            return ACCESS_DENIED;
        var elem = _map._data[addr];
        var exists = elem._nickname != 0;
        if (!exists)
            return RESOURCE_NOT_FOUND;
        else
            elem._dataHash = dataHash;
    }

    function removeUser(address addr) returns (uint16 error) {
        if (!_checkCaller())
            return ACCESS_DENIED;
        var elem = _map._data[addr];
        var exists = elem._nickname != 0;
        if (!exists)
            return RESOURCE_NOT_FOUND;
        var keyIndex = elem._keyIndex;
        delete _map._data[addr];
        var len = _map._keys.length;
        if (keyIndex != len - 1) {
            var swap = _map._keys[len - 1];
            _map._keys[keyIndex] = swap;
            _map._data[swap]._keyIndex = keyIndex;
        }
        _map._keys.length--;
    }

    function user(address addr) constant returns (bytes32 value_nickname, uint value_timestamp, bytes32 value_dataHash) {
        var elem = _map._data[addr];
        value_nickname = elem._nickname;
        value_timestamp = elem._timestamp;
        value_dataHash = elem._dataHash;
    }

    function hasUser(address addr) constant returns (bool has) {
        return _map._data[addr]._nickname != 0;
    }

    function hasUsers(address addr1, address addr2) constant returns (bool has1, bool has2){
        has1 = _map._data[addr1]._nickname != 0;
        has2 = _map._data[addr2]._nickname != 0;
    }

    function userAddressFromIndex(uint index) constant returns (address addr, uint16 error) {
        if (index >= _map._keys.length) {
            error = ARRAY_INDEX_OUT_OF_BOUNDS;
            return;
        }
        addr = _map._keys[index];
    }

    function size() constant returns (uint size){
        return _map._keys.length;
    }

    function destroy(address caller){}

}