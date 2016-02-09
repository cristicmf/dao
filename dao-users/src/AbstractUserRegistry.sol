/*
    File: AbstractUserRegistry.sol
    Author: Andreas Olofsson (androlo1980@gmail.com)
*/
import "dao-core/src/Doug.sol";
import "./UserRegistry.sol";
import "./UserDatabase.sol";

/*
    Contract: AbstractUserRegistry

    User registry contract. Depends on a 'UserDatabase' contract.

    Base contract for administrated user accounts.

    Uses a single admin account.

    The admin can remove users and edit their data.
*/
contract AbstractUserRegistry is UserRegistry, DefaultDougEnabled {

    address _admin;
    UserDatabase _userDatabase;

    /*
        Constructor: AbstractUserRegistry

        Params:
            dbAddress (address) - The address to the user database.
            admin (address) - The address of the admin account.
    */
    function AbstractUserRegistry(address dbAddress, address admin) {
        _userDatabase = UserDatabase(dbAddress);
        _admin = admin;
    }

    /*
        Function: registerUser

        Register a new user. Must be 'admin'. Fires a <UserRegistry.RegisterUser> event.

        Params:
            addr (address) - The address.
            nickname (bytes32) - The users nickname.
            dataHash (bytes32) - Hash of the file containing (optional) user data.

        Returns:
            error (uint16) - An error code.
    */
    function registerUser(address addr, bytes32 nickname, bytes32 dataHash) returns (uint16 error) {
        if (msg.sender != _admin)
            error = ACCESS_DENIED;
        else if (addr == 0 || nickname == 0)
            error = NULL_PARAM_NOT_ALLOWED;
        else
            error = _userDatabase.registerUser(addr, nickname, block.timestamp, dataHash);
        RegisterUser(addr, nickname, dataHash, error);
    }

    /*
        Function: removeUser

        Remove a user. Must be 'admin' or the user account.

        Params:
            addr (address) - The user address.

        Returns:
            error (uint16) - An error code.
    */
    function removeUser(address addr) returns (uint16 error) {
        if (msg.sender != _admin && msg.sender != addr)
            error = ACCESS_DENIED;
        else if (addr == 0)
            error = NULL_PARAM_NOT_ALLOWED;
        else
            error = _userDatabase.removeUser(addr);

        RemoveUser(addr, error);
    }

    /*
        Function: removeSelf

        Remove the sender account.

        Returns:
            error (uint16) - An error code.
    */
    function removeSelf() returns (uint16 error) {
        error = _userDatabase.removeUser(msg.sender);
        RemoveUser(msg.sender, error);
    }

    /*
        Function: updateDataHash

        Update a users data-hash. Must be 'admin' or the user account.

        Params:
            addr (address) - The address.
            dataHash (bytes32) - Hash of the file containing (optional) user data.

        Returns:
            error (uint16) - An error code.
    */
    function updateDataHash(address addr, bytes32 dataHash) returns (uint16 error) {
        if (msg.sender != _admin && msg.sender != addr)
            error = ACCESS_DENIED;
        else if (addr == 0)
            error = NULL_PARAM_NOT_ALLOWED;
        else
            error =  _userDatabase.updateDataHash(addr, dataHash);

        UpdateDataHash(addr, dataHash, error);
    }

    /*
        Function: updateMyDataHash

        Update the sender data-hash.

        Params:
            dataHash (bytes32) - Hash of the file containing (optional) user data.

        Returns:
            error (uint16) - An error code.
    */
    function updateMyDataHash(bytes32 dataHash) returns (uint16 error) {
        error = _userDatabase.updateDataHash(msg.sender, dataHash);
        UpdateDataHash(msg.sender, dataHash, error);
    }

    /*
        Function: setMaxUsers

        Set the maximum number of users that are allowed in the group.

        Params:
            maxUsers (uint) - The maximum number of users.

        Returns:
            error (uint16) - An error code.
    */
    function setMaxUsers(uint maxUsers) returns (uint16 error) {
        if (msg.sender != _admin)
            error = ACCESS_DENIED;
        else
            error = _userDatabase.setMaxSize(maxUsers);
        SetMaxUsers(maxUsers, error);
    }

    /*
        Function: setUserDatabase

        Set the address of the user database. Must be 'admin'.

        Params:
            dbAddr (address) - The database address.

        Returns:
            error (uint16) - An error code.
    */
    function setUserDatabase(address dbAddr) returns (uint16 error) {
        if (msg.sender != _admin)
            error = ACCESS_DENIED;
        else
            _userDatabase = UserDatabase(dbAddr);

        SetUserDatabase(dbAddr, error);
    }

    /*
        Function: userDatabase

        Get the address of the user database.

        Returns:
            dbAddr (address) - The database address.
    */
    function userDatabase() returns (address dbAddr) {
        return _userDatabase;
    }


    /*
        Function: setAdmin

        Set the admin account. Can only be done by the current admin.

        Params:
            addr (address) - The admin address.

        Returns:
            error (uint16) - An error code.
    */
    function setAdmin(address addr) returns (uint16 error) {
        if (msg.sender != _admin)
            error = ACCESS_DENIED;
        else
            _admin = addr;

        SetAdmin(addr, error);
    }

    /*
        Function: admin

        Get the admin account.

        Returns:
            addr (address) - The admin address.
    */
    function admin() returns (address addr) {
        return _admin;
    }

}