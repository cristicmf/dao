import "./AdminUserRegistry.sol";

/// @title UserRegistryAdminReg
/// @author Andreas Olofsson (androlo1980@gmail.com)
/// @dev User registry contract. Depends on a 'UserDatabase' contract.
/// All users must be registered by an administrator, but the users can remove themselves and edit their data.
/// This contract uses a single admin account.
contract UserRegistryAdminReg is AdminUserRegistry {


    function UserRegistryAdminReg(address dbAddress, address admin) AdminUserRegistry(dbAddress, admin) {}

    /// @notice UserRegistryAdminReg.registerUser(addr, nickname, dataHash) to register a new user.
    /// @dev Register a new user.
    /// @param addr (address) the address.
    /// @param nickname (bytes32) the user nick.
    /// @param dataHash (bytes32) hash of the file containing user data.
    /// @return error (uint16) error code.
    function registerUser(address addr, bytes32 nickname, bytes32 dataHash) returns (uint16 error){
        if(msg.sender != _admin){
            return ACCESS_DENIED;
        }
        if(addr == 0 || nickname == 0){
            return NULL_PARAM_NOT_ALLOWED;
        }
        return _udb.registerUser(addr, nickname, block.timestamp, dataHash);
    }

}