import "../../../dao-stl/contracts/src/errors/Errors.sol";
import "../../../dao-core/contracts/src/Doug.sol";
import "./UserRegistry.sol";
import "./UserDatabase.sol";

/*
    Contract: AbstractUserRegistry

    User registry contract. Depends on a 'UserDatabase' contract.

    Base contract for administrated user accounts.

    Uses a single admin account.

    The admin can remove users and edit their data.

    Author: Andreas Olofsson (androlo1980@gmail.com)
*/
contract AbstractUserRegistry is UserRegistry, DefaultDougEnabled, Errors {

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

        Register a new user. Must be 'admin'.

        Params:
            addr (address) - The address.
            nickname (bytes32) - The users nickname.
            dataHash (bytes32) - Hash of the file containing (optional) user data.

        Returns:
            error (uint16) - An error code.
    */
    function registerUser(address addr, bytes32 nickname, bytes32 dataHash) returns (uint16 error) {
        if (msg.sender != _admin)
            return ACCESS_DENIED;
        if (addr == 0 || nickname == 0)
            return NULL_PARAM_NOT_ALLOWED;
        return _userDatabase.registerUser(addr, nickname, block.timestamp, dataHash);
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
            return ACCESS_DENIED;
        if (addr == 0)
            return NULL_PARAM_NOT_ALLOWED;
        return _userDatabase.removeUser(addr);
    }

    /*
        Function: removeSelf

        Remove the sender account.

        Returns:
            error (uint16) - An error code.
    */
    function removeSelf() returns (uint16 error) {
        return _userDatabase.removeUser(msg.sender);
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
            return ACCESS_DENIED;
        if (addr == 0)
            return NULL_PARAM_NOT_ALLOWED;
        return _userDatabase.updateDataHash(addr, dataHash);
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
        return _userDatabase.updateDataHash(msg.sender, dataHash);
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
            return ACCESS_DENIED;
        _userDatabase = UserDatabase(dbAddr);
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
            return ACCESS_DENIED;
        _admin = addr;
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