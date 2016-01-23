import "./AbstractSingleAdminUserRegistry.sol";

/// @title UserRegistryAdminReg
/// @author Andreas Olofsson (androlo1980@gmail.com)
/// @dev User registry contract. Depends on a 'UserDatabase' contract.
/// All users must be registered by an administrator, but the users can remove themselves and edit their data.
/// This contract uses a single admin account.
contract UserRegistryAdminReg is AbstractSingleAdminUserRegistry {

    function UserRegistryAdminReg(address dbAddress, address admin)
        AbstractSingleAdminUserRegistry(dbAddress, admin) {}

    function registerSelf(bytes32 nickname, bytes32 dataHash) returns (uint16 error) {
        return ACCESS_DENIED;
    }

}