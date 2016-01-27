import "../../../dao-core/contracts/src/Database.sol";
import "../../../dao-stl/src/errors/Errors.sol";

/// @title DefaultUserDatabase
/// @author Andreas Olofsson (androlo1980@gmail.com)
/// @dev DefaultUserDatabase is an iterable map with (address, UserData) entries. Order of insertion is not preserved.
/// O(1) insert, find, and remove.
/// Stores an array index (uint) for each entry, in addition to the key and value.
/// This is for easy lookup, and for making iteration possible.
/// Order of insertion is not preserved.
contract DefaultUserDatabase is DefaultDatabase {

    struct Element {
        // For backing array.
        uint _keyIndex;
        // User data
        bytes32 nickname;
        uint timestamp;
        bytes32 dataHash;
    }

    mapping(bytes32 => address) _nToA;
    mapping(address => Element) _data;
    address[] _keys;

    /// @notice DefaultUserDatabase.registerUser(addr, value_nickname, value_timestamp, value_dataHash) to register a new user. Overwriting not allowed.
    /// @dev Register a new user.
    /// @param addr (address) the address.
    /// @param value_nickname (bytes32) the user name.
    /// @param value_timestamp (uint) the unix timestamp.
    /// @param value_dataHash (bytes32) hash of the file containing (optional) user data.
    /// @return error (uint16) error code.
    function registerUser(address addr, bytes32 value_nickname, uint value_timestamp, bytes32 value_dataHash) returns (uint16 error) {
        if (!_checkCaller())
            return ACCESS_DENIED;
        var exists = _data[addr].nickname != 0 || _nToA[value_nickname] != 0;
        if (exists)
            return RESOURCE_ALREADY_EXISTS;
        else {
            var keyIndex = _keys.length++;
            _data[addr] = Element(keyIndex, value_nickname, value_timestamp, value_dataHash);
            _keys[keyIndex] = addr;
        }
    }

    /// @notice DefaultUserDatabase.updateDataHash(addr, dataHash) to register a new data-hash for a user.
    /// @dev Register a new data hash for a user.
    /// @param addr (address) the address.
    /// @param dataHash (bytes32) hash of the file containing user data.
    /// @return error (uint16) error code.
    function updateDataHash(address addr, bytes32 dataHash) returns (uint16 error) {
        if (!_checkCaller())
            return ACCESS_DENIED;
        var elem = _data[addr];
        var exists = elem.nickname != 0;
        if (!exists)
            return RESOURCE_NOT_FOUND;
        else
            elem.dataHash = dataHash;
    }

    /// @notice DefaultUserDatabase.removeUser(addr) to remove a user.
    /// @dev Remove a user.
    /// @param addr (address) the user address.
    /// @return error (uint16) error code.
    function removeUser(address addr) returns (uint16 error) {
        if (!_checkCaller())
            return ACCESS_DENIED;
        var elem = _data[addr];
        var exists = elem.nickname != 0;
        if (!exists)
            return RESOURCE_NOT_FOUND;
        var keyIndex = elem._keyIndex;
        delete _data[addr];
        var len = _keys.length;
        if (keyIndex != len - 1) {
            var swap = _keys[len - 1];
            _keys[keyIndex] = swap;
            _data[swap]._keyIndex = keyIndex;
        }
        _keys.length--;
    }

    /// @notice DefaultUserDatabase.user(addr) to get user data.
    /// @dev Get user data from the user address.
    /// @param addr (address) the address.
    /// @return value_nickname (bytes32) the nickname|
    /// @return value_timestamp (uint) the time when the user was added|
    /// @return value_dataHash (bytes32) the data-hash (optional).
    function user(address addr) constant returns (bytes32 value_nickname, uint value_timestamp, bytes32 value_dataHash) {
        var elem = _data[addr];
        value_nickname = elem.nickname;
        value_timestamp = elem.timestamp;
        value_dataHash = elem.dataHash;
    }

    /// @notice DefaultUserDatabase.user(nickname) to get user data.
    /// @dev Get user data from the nickname.
    /// @param nickname (bytes32) the nickname.
    /// @return value_nickname (bytes32) the nickname|
    /// @return value_timestamp (uint) the time when the user was added|
    /// @return value_dataHash (bytes32) the data-hash (optional).
    function user(bytes32 nickname) constant returns (bytes32 value_nickname, uint value_timestamp, bytes32 value_dataHash){
        var addr = _nToA[nickname];
        if (addr == 0)
            return;
        var elem = _data[addr];
        value_nickname = elem.nickname;
        value_timestamp = elem.timestamp;
        value_dataHash = elem.dataHash;
    }

    /// @notice DefaultUserDatabase.hasUser(addr) to check if a user exists.
    /// @dev Check if a user exists.
    /// @param addr (address) the address.
    /// @return has (bool) whether or not the user exists.
    function hasUser(address addr) constant returns (bool has) {
        return _data[addr].nickname != 0;
    }

    /// @notice DefaultUserDatabase.hasUser(nickname) to check if a user exists.
    /// @dev Check if a user exists.
    /// @param nickname (bytes32) the nickname.
    /// @return has (bool) whether or not the user exists.
    function hasUser(bytes32 nickname) constant returns (bool has) {
        return _nToA[nickname] != 0;
    }

    /// @notice DefaultUserDatabase.hasUsers(addr1, addr2) to check if two users exists.
    /// @dev Check if two users exists. Convenience function for user-to-user interaction checks.
    /// @param addr1 (address) the address of the first user.
    /// @param addr2 (address) the address of the second user.
    /// @return has1 (bool) whether or not the first user exists|
    /// @return has2 (bool) whether or not the second user exists
    function hasUsers(address addr1, address addr2) constant returns (bool has1, bool has2) {
        has1 = _data[addr1].nickname != 0;
        has2 = _data[addr2].nickname != 0;
    }

    /// @notice DefaultUserDatabase.hasUsers(addr1, addr2) to check if two users exists.
    /// @dev Check if two users exists. Convenience function for user-to-user interaction checks.
    /// @param nickname1 (bytes32) the first nickname.
    /// @param nickname2 (bytes32) the second nickname.
    /// @return has1 (bool) whether or not the first user exists|
    /// @return has2 (bool) whether or not the second user exists
    function hasUsers(bytes32 nickname1, bytes32 nickname2) constant returns (bool has1, bool has2) {
        has1 = _nToA[nickname1] != 0;
        has2 = _nToA[nickname2] != 0;
    }

    /// @notice DefaultUserDatabase.userAddressFromIndex(index) to get a user address by its index in the backing array.
    /// @dev Get a user address by its index in the backing array.
    /// @param index (uint) the index.
    /// @return key (address) the key|
    /// @return error (uint16) error code
    function userAddressFromIndex(uint index) constant returns (address addr, uint16 error) {
        if (index >= _keys.length) {
            error = ARRAY_INDEX_OUT_OF_BOUNDS;
            return;
        }
        addr = _keys[index];
    }

    /// @notice DefaultUserDatabase.size() to get the number of users.
    /// @dev Get the number of users.
    /// @return size (uint) the number of users.
    function size() constant returns (uint size) {
        return _keys.length;
    }

}