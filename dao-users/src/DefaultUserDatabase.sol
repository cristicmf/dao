/*
    File: DefaultUserDatabase.sol

    Author: Andreas Olofsson (androlo1980@gmail.com)
*/
import "dao-core/src/Database.sol";
import "dao-stl/src/errors/Errors.sol";

/*
    Contract: DefaultUserDatabase

    DefaultUserDatabase is an iterable map with (address, UserData) entries. Order of insertion is not preserved.

    O(1) insert, find, and remove.

    Stores an array index (uint) for each entry, in addition to the key and value.
    This is for easy lookup, and for making iteration possible.

    Order of insertion is not preserved.

    A max-size of 0 means no upper limit. This is the default value.
*/
contract DefaultUserDatabase is DefaultDatabase {

    /*
        Struct: Element

        Element type for the user map.

        Members:
            _keyIndex - Used for iteration.
            nickname - The user nickname.
            timestamp - The (unix) time when the user was registered.
            dataHash - The hash to the file containing user data.
    */
    struct Element {
        // For backing array.
        uint _keyIndex;
        // User data
        bytes32 nickname;
        uint timestamp;
        bytes32 dataHash;
    }

    uint _maxSize;

    mapping(bytes32 => address) _nToA;
    mapping(address => Element) _data;
    address[] _keys;

    /*
        Function: registerUser

        Register a new user.

        Params:
            addr (address) - The address.
            value_nickname (bytes32) - The users nickname.
            value_timestamp (uint) - A unix timestamp.
            value_dataHash (bytes32) - Hash of the file containing (optional) user data.

        Returns:
            error (uint16) An error code.
    */
    function registerUser(address addr, bytes32 value_nickname, uint value_timestamp, bytes32 value_dataHash) returns (uint16 error) {
        if (!_checkCaller())
            return ACCESS_DENIED;
        var exists = _data[addr].nickname != 0 || _nToA[value_nickname] != 0;
        if (exists)
            return RESOURCE_ALREADY_EXISTS;
        if (_maxSize != 0 && _keys.length == _maxSize)
            return ARRAY_INDEX_OUT_OF_BOUNDS;
        else
            _data[addr] = Element(_keys.push(addr) - 1, value_nickname, value_timestamp, value_dataHash);
    }

    /*
        Function: updateDataHash

        Update a users data-hash.

        Params:
            addr (address) - The address.
            dataHash (bytes32) - Hash of the file containing (optional) user data.

        Returns:
            error (uint16) An error code.
    */
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

    /*
        Function: removeUser

        Remove a user.

        Params:
            addr (address) - The user address.

        Returns:
            error (uint16) An error code.
    */
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

    /*
        Function: user(address)

        Get user data from the user address.

        Params:
            addr (address) - The address.

        Returns:
            value_nickname (bytes32) - The users nickname.
            value_timestamp (uint) - The unix time of when the user was added.
            value_dataHash (bytes32) - Hash of the file containing (optional) user data.
    */
    function user(address addr) constant returns (bytes32 value_nickname, uint value_timestamp, bytes32 value_dataHash) {
        var elem = _data[addr];
        return (elem.nickname, elem.timestamp, elem.dataHash);
    }

    /*
        Function: user(bytes32)

        Get user data from the nickname.

        Params:
            nickname (bytes32) - The nickname.

        Returns:
            value_nickname (bytes32) - The users nickname.
            value_timestamp (uint) - The unix time of when the user was added.
            value_dataHash (bytes32) - Hash of the file containing (optional) user data.
    */
    function user(bytes32 nickname) constant returns (bytes32 value_nickname, uint value_timestamp, bytes32 value_dataHash){
        var addr = _nToA[nickname];
        if (addr == 0)
            return;
        var elem = _data[addr];
        return (elem.nickname, elem.timestamp, elem.dataHash);
    }

    /*
        Function: hasUser(address)

        Check if a user exists.

        Params:
            addr (address) - The address.

        Returns:
            has (bool) - Whether or not the user exists.
    */
    function hasUser(address addr) constant returns (bool has) {
        return _data[addr].nickname != 0;
    }

    /*
        Function: hasUser(bytes32)

        Check if a user exists.

        Params:
            nickname (bytes32) - The nickname.

        Returns:
            has (bool) - Whether or not the user exists.
    */
    function hasUser(bytes32 nickname) constant returns (bool has) {
        return _nToA[nickname] != 0;
    }

    /*
        Function: hasUsers(address, address)

        Check if two users exists. Convenience function for user-to-user interaction checks.

        Params:
            addr1 (address) - The address of the first user.
            addr2 (address) - The address of the second user.

        Returns:
            has1 (bool) - Whether or not the first user exists.
            has2 (bool) - Whether or not the second user exists.
    */
    function hasUsers(address addr1, address addr2) constant returns (bool has1, bool has2) {
        return(_data[addr1].nickname != 0, _data[addr2].nickname != 0);
    }

    /*
        Function: hasUser(bytes32, bytes32)

        Check if two users exists. Convenience function for user-to-user interaction checks.

        Params:
            nickname1 (bytes32) - The nickname of the first user.
            nickname2 (bytes32) - The nickname of the second user.

        Returns:
            has1 (bool) - Whether or not the first user exists.
            has2 (bool) - Whether or not the second user exists.
    */
    function hasUsers(bytes32 nickname1, bytes32 nickname2) constant returns (bool has1, bool has2) {
        return(_nToA[nickname1] != 0, _nToA[nickname2] != 0);
    }

    /*
        Function: userAddressFromIndex

        Get a user address from their index in the backing array.

        Params:
            index (uint) - The index.

        Returns:
            addr (address) - The user address
            error (uint16) - An error code.
    */
    function userAddressFromIndex(uint index) constant returns (address addr, uint16 error) {
        if (index >= _keys.length) {
            error = ARRAY_INDEX_OUT_OF_BOUNDS;
            return;
        }
        addr = _keys[index];
    }

    /*
        Function: userFromIndex

        Get user data from their index in the backing array.

        Params:
            index (uint) - The index.

        Returns:
            addr (address) - The user address.
            nickname (bytes32) - The nickname.
            timestamp (uint) - The timestamp from when the user was added.
            dataHash (bytes32) - The data-hash.
            error (uint16) - An error code.
    */
    function userFromIndex(uint index) constant returns (
        address addr,
        bytes32 nickname,
        uint timestamp,
        bytes32 dataHash,
        uint16 error
    ) {
        if (index >= _keys.length) {
            error = ARRAY_INDEX_OUT_OF_BOUNDS;
            return;
        }
        addr = _keys[index];
        var elem = _data[addr];
        nickname = elem.nickname;
        timestamp = elem.timestamp;
        dataHash = elem.dataHash;
    }


    /*
        Function: size

        Get the total number of users.

        Returns:
            size (uint) - The size of the collection of users.
    */
    function size() constant returns (uint size) {
        return _keys.length;
    }

    /*
        Function: setMaxSize

        Set the maximum number of users allowed.

        Params:
            maxSize (uint) - The user address.

        Returns:
            error (uint16) An error code.
    */
    function setMaxSize(uint maxSize) returns (uint16 error) {
        if (!_checkCaller())
            return ACCESS_DENIED;
        if (maxSize != 0 && _keys.length > maxSize)
            return INTEGER_OUT_OF_BOUNDS;
        _maxSize = maxSize;
    }

    /*
        Function: maxSize

        Get the maximum number of users allowed.

        Returns:
            size (uint) - The maximum size.
    */
    function maxSize() constant returns (uint maxSize) {
        return _maxSize;
    }

}