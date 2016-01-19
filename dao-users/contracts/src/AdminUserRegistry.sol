import "../../../dao-stl/src/errors/Errors.sol";
import "./UserDatabase.sol";

/// @title AdminUserRegistry
/// @author Andreas Olofsson (androlo1980@gmail.com)
/// @dev User registry contract. Depends on a 'UserDatabase' contract.
/// Base contract for administrated user accounts. Admins can remove users and edit their data.
/// This contract uses a single admin account.
contract AdminUserRegistry is Errors {

    address _admin;
    UserDatabase _udb;

    function AdminUserRegistry(address dbAddress, address admin){
        _udb = UserDatabase(dbAddress);
        _admin = admin;
    }

    /// @notice AdminUserRegistry.removeUser(addr) to remove a user.
    /// @dev Remove a user.
    /// @param addr (address) the address.
    /// @return error (uint16) error code.
    function removeUser(address addr) returns (uint16 error){
        if(msg.sender != _admin && msg.sender != addr){
            return ACCESS_DENIED;
        }
        if(addr == 0){
            return NULL_PARAM_NOT_ALLOWED;
        }
        return _udb.removeUser(addr);
    }

    /// @notice AdminUserRegistry.removeUser(addr) to remove yourself as a user.
    /// @dev Remove yourself as a user.
    /// @return error (uint16) error code.
    function removeUser() returns (uint16 error){
        return _udb.removeUser(msg.sender);
    }

    /// @notice AdminUserRegistry.updateDataHash(addr, dataHash) to register a new data-hash.
    /// @dev Register a new data-hash.
    /// @param addr (address) the address.
    /// @param dataHash (bytes32) hash of the file containing user data.
    /// @return error (uint16) error code.
    function updateDataHash(address addr, bytes32 dataHash) returns (uint16 error){
        if(msg.sender != _admin){
            return ACCESS_DENIED;
        }
        if(addr == 0){
            return NULL_PARAM_NOT_ALLOWED;
        }
        return _udb.updateDataHash(addr, dataHash);
    }

    /// @notice AdminUserRegistry.updateDataHash(dataHash) to register a new data-hash for yourself.
    /// @dev Register a new data-hash for yourself.
    /// @param dataHash (bytes32) hash of the file containing user data.
    /// @return error (uint16) error code.
    function updateDataHash(bytes32 dataHash) returns (uint16 error){
        return _udb.updateDataHash(msg.sender, dataHash);
    }

}