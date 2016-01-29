import "./AbstractUserRegistry.sol";

/*
    Contract: AdminRegUserRegistry

    User registry contract. Depends on a 'UserDatabase' contract.
    All users must be registered by an administrator.

    Author: Andreas Olofsson (androlo1980@gmail.com)
*/
contract AdminRegUserRegistry is AbstractUserRegistry {

    /*
        Constructor: AdminRegUserRegistry

        Params:
            dbAddress (address) - The address to the user database.
            admin (address) - The address of the admin account.
    */
    function AdminRegUserRegistry(address dbAddress, address admin)
        AbstractUserRegistry(dbAddress, admin) {}

    /*
        Function: registerSelf

        Register the sender account as a new user. Can only be used by 'admin' to register themselves.

        Params:
            nickname (bytes32) - The nickname.
            dataHash (bytes32) - Hash of the file containing (optional) user data.

        Returns:
            error (uint16) An error code.
    */
    function registerSelf(bytes32 nickname, bytes32 dataHash) returns (uint16 error) {
        if (nickname == 0)
            return NULL_PARAM_NOT_ALLOWED;
        if (msg.sender != _admin)
            return ACCESS_DENIED;
        return _udb.registerUser(msg.sender, nickname, block.timestamp, dataHash);
    }

}