/*
    File: UserDatabase.sol

    Author: Andreas Olofsson (androlo1980@gmail.com)
*/
import "dao-core/src/Database.sol";

/*
    Contract: UserDatabase

    UserDatabase is an interface for contracts that keeps an iterable record of users.

*/
contract UserDatabase is Database {

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
    function registerUser(address addr, bytes32 value_nickname, uint value_timestamp, bytes32 value_dataHash) returns (uint16 error);

    /*
        Function: updateDataHash

        Update a users data-hash.

        Params:
            addr (address) - The address.
            dataHash (bytes32) - Hash of the file containing (optional) user data.
        Returns:
            error (uint16) An error code.
    */
    function updateDataHash(address addr, bytes32 dataHash) returns (uint16 error);

    /*
        Function: setProperty

        Set a generic property.

        Params:
            addr (address) - The address.
            propName (bytes32) - The name of the property
            value (bool) - 'true' to set the property, 'false' to unset.
        Returns:
            error (uint16) An error code.
    */
    function setProperty(address addr, bytes32 propName, bool value) returns (uint16 error);

    /*
        Function: removeUser

        Remove a user.

        Params:
            addr (address) - The user address.

        Returns:
            error (uint16) An error code.
    */
    function removeUser(address addr) returns (uint16 error);

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
    function user(address addr) constant returns (bytes32 value_nickname, uint value_timestamp, bytes32 value_dataHash);

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
    function user(bytes32 nickname) constant returns (bytes32 value_nickname, uint value_timestamp, bytes32 value_dataHash);

    /*
        Function: hasUser(address)

        Check if a user exists.

        Params:
            addr (address) - The address.

        Returns:
            has (bool) - Whether or not the user exists.
    */
    function hasUser(address addr) constant returns (bool has);

    /*
        Function: hasUser(bytes32)

        Check if a user exists.

        Params:
            nickname (bytes32) - The nickname.

        Returns:
            has (bool) - Whether or not the user exists.
    */
    function hasUser(bytes32 nickname) constant returns (bool has);

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
    function hasUsers(address addr1, address addr2) constant returns (bool has1, bool has2);

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
    function hasUsers(bytes32 nickname1, bytes32 nickname2) constant returns (bool has1, bool has2);

    /*
        Function: hasProperty(address)

        Check if a user has the given property.

        Params:
            userAddress (address) - The user address.
            property (bytes32) - The property.

        Returns:
            has (bool) - Whether or not the user has the property.
            error (uint16) - An error code.
    */
    function hasProperty(address userAddress, bytes32 property) constant returns (bool hasProperty, uint16 error);

    /*
        Function: hasProperty(bytes32)

        Check if a user has the given property.

        Params:
            nickname (bytes32) - The user nickname.
            property (bytes32) - The property.

        Returns:
            has (bool) - Whether or not the user has the property.
            error (uint16) - An error code.
    */
    function hasProperty(bytes32 nickname, bytes32 property) constant returns (bool hasProperty, uint16 error);

    /*
        Function: userAddressFromIndex

        Get a user address from their index in the backing array.

        Params:
            index (uint) - The index.

        Returns:
            addr (address) - The user address
            error (uint16) - An error code.
    */
    function userAddressFromIndex(uint index) constant returns (address addr, uint16 error);

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
    function userFromIndex(uint index) constant returns (address addr, bytes32 nickname, uint timestamp, bytes32 dataHash, uint16 error);

    /*
        Function: size

        Get the total number of users.

        Returns:
            size (uint) - The size of the collection of users.
    */
    function size() constant returns (uint size);

    /*
        Function: setMaxSize

        Set the maximum number of users allowed.

        Params:
            maxSize (uint) - The user address.

        Returns:
            error (uint16) An error code.
    */
    function setMaxSize(uint maxSize) returns (uint16 error);

    /*
        Function: maxSize

        Get the total number of users allowed.

        Returns:
            size (uint) - The maximum size.
    */
    function maxSize() constant returns (uint maxSize);

}