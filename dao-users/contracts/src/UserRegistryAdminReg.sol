import "./AbstractSingleAdminUserRegistry.sol";

/// @title UserRegistryAdminReg
/// @author Andreas Olofsson (androlo1980@gmail.com)
/// @dev User registry contract. Depends on a 'UserDatabase' contract.
/// All users must be registered by an administrator, but the users can remove themselves and edit their data.
/// This contract uses a single admin account.
contract UserRegistryAdminReg is AbstractSingleAdminUserRegistry {

    function UserRegistryAdminReg(address dbAddress, address admin)
        AbstractSingleAdminUserRegistry(dbAddress, admin) {}

    /// @notice UserRegistryAdminReg.registerSelf(nickname, dataHash) to register a new user.
    /// @dev Register a new user. This can't be done except by 'admin'.
    /// @param nickname (bytes32) the user nick.
    /// @param dataHash (bytes32) hash of the file containing user data.
    /// @return error (uint16) error code.
    function registerSelf(bytes32 nickname, bytes32 dataHash) returns (uint16 error) {
        if (nickname == 0)
            return NULL_PARAM_NOT_ALLOWED;
        if (msg.sender != _admin)
            return ACCESS_DENIED;
        return _udb.registerUser(msg.sender, nickname, block.timestamp, dataHash);
    }

}