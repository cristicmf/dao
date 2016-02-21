/*
    File: UserRegistry.sol

    Author: Andreas Olofsson (androlo1980@gmail.com)
*/
import "dao-core/src/Doug.sol";

/*
    Contract: UserRegistry

    An interface for contracts that works with a user database to register and manage users.
*/
contract UserRegistry is DougEnabled {

    /*
        Event: RegisterUser

        Params:
            addr (address) - The address.
            nickname (bytes32) - The users nickname.
            dataHash (bytes32) - Hash of the file containing (optional) user data.
            error (uint16) - An error code.
    */
    event RegisterUser(address indexed addr, bytes32 indexed nickname, bytes32 indexed dataHash, uint16 error);


    /*
        Event: RemoveUser

        Params:
            addr (address) - The user address.
            error (uint16) - An error code.
    */
    event RemoveUser(address indexed addr, uint16 indexed error);

    /*
        Event: UpdateDataHash

        Params:
            addr (address) - The address.
            dataHash (bytes32) - Hash of the file containing (optional) user data.
            error (uint16) - An error code.
    */
    event UpdateDataHash(address indexed addr, bytes32 indexed dataHash, uint16 indexed error);

    /*
        Event: SetUserDatabase

        Params:
            dbAddr (address) - The address.
            error (uint16) - An error code.
    */
    event SetUserDatabase(address indexed dbAddr, uint16 indexed error);

    /*
        Event: SetProperty

        Params:
            userAddr (address) - The user address.
            propName (bytes32) - The name of the property
            value (bool) - 'true' to set the property, 'false' to unset.
            error (uint16) - An error code.
    */
    event SetProperty(address indexed userAddr, bytes32 indexed propName, bool indexed value, uint16 error);

    /*
        Event: SetAdmin

        Params:
            dbAddr (address) - The address.
            error (uint16) - An error code.
    */
    event SetAdmin(address indexed dbAddr, uint16 indexed error);

    /*
        Event: SetMaxUsers

        Params:
            maxUsers (uint) - The address.
            error (uint16) - An error code.
    */
    event SetMaxUsers(uint indexed maxUsers, uint16 indexed error);

    /*
        Function: registerUser

        Register a new user.

        Params:
            addr (address) - The address.
            nickname (bytes32) - The users nickname.
            dataHash (bytes32) - Hash of the file containing (optional) user data.

        Returns:
            error (uint16) - An error code.
    */
    function registerUser(address addr, bytes32 nickname, bytes32 dataHash) returns (uint16 error);

    /*
        Function: registerSelf

        Register the sender account as a new user.

        Params:
            nickname (bytes32) - The nickname.
            dataHash (bytes32) - Hash of the file containing (optional) user data.

        Returns:
            error (uint16) - An error code.
    */
    function registerSelf(bytes32 nickname, bytes32 dataHash) returns (uint16 error);

    /*
        Function: removeUser

        Remove a user.

        Params:
            addr (address) - The user address.

        Returns:
            error (uint16) - An error code.
    */
    function removeUser(address addr) returns (uint16 error);

    /*
        Function: removeSelf

        Remove the sender account.

        Returns:
            error (uint16) - An error code.
    */
    function removeSelf() returns (uint16 error);

    /*
        Function: updateDataHash

        Update a users data-hash.

        Params:
            addr (address) - The address.
            dataHash (bytes32) - Hash of the file containing (optional) user data.

        Returns:
            error (uint16) - An error code.
    */
    function updateDataHash(address addr, bytes32 dataHash) returns (uint16 error);

    /*
        Function: updateMyDataHash

        Update the sender data-hash.

        Params:
            dataHash (bytes32) - Hash of the file containing (optional) user data.

        Returns:
            error (uint16) - An error code.
    */
    function updateMyDataHash(bytes32 dataHash) returns (uint16 error);

    /*
        Function: setProperty

        Set a generic property.

        Params:
            userAddr (address) - The user-address.
            propName (bytes32) - The name of the property
            value (bool) - 'true' to set the property, 'false' to unset.
        Returns:
            error (uint16) An error code.
    */
    function setProperty(address userAddr, bytes32 propName, bool value) returns (uint16 error);

    /*
        Function: setMaxUsers

        Set the maximum number of users that are allowed in the group.

        Params:
            maxUsers (uint) - The maximum number of users.

        Returns:
            error (uint16) - An error code.
    */
    function setMaxUsers(uint maxUsers) returns (uint16 error);

    /*
        Function: setUserDatabase

        Set the address of the user database.

        Params:
            dbAddr (address) - The database address.

        Returns:
            error (uint16) - An error code.
    */
    function setUserDatabase(address dbAddr) returns (uint16 error);

    /*
        Function: userDatabase

        Get the address of the user database.

        Returns:
            dbAddr (address) - The database address.
    */
    function userDatabase() constant returns (address dbAddr);

    /*
        Function: setAdmin

        Set the admin account.

        Params:
            addr (address) - The admin address.

        Returns:
            error (uint16) - An error code.
    */
    function setAdmin(address addr) returns (uint16 error);

    /*
        Function: admin

        Get the admin account.

        Returns:
            addr (address) - The admin address.
    */
    function admin() constant returns (address addr);

}