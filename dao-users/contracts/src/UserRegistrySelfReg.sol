import "./AbstractSingleAdminUserRegistry.sol";

/// @title UserRegistrySelfReg
/// @author Andreas Olofsson (androlo1980@gmail.com)
/// @dev User registry contract. Depends on a 'UserDatabase' contract.
/// Users can register themselves.
contract UserRegistrySelfReg is AbstractSingleAdminUserRegistry {

    function UserRegistrySelfReg(address dbAddress, address admin)
        AbstractSingleAdminUserRegistry(dbAddress, admin) {}

    function registerSelf(bytes32 nickname, bytes32 dataHash) returns (uint16 error) {
        if (nickname == 0)
            return NULL_PARAM_NOT_ALLOWED;
        return _udb.registerUser(msg.sender, nickname, block.timestamp, dataHash);
    }

}