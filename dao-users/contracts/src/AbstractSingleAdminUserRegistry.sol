import "../../../dao-stl/src/errors/Errors.sol";
import "../../../dao-core/contracts/src/Doug.sol";
import "./UserRegistry.sol";
import "./UserDatabase.sol";

/// @title AbstractSingleAdminUserRegistry
/// @author Andreas Olofsson (androlo1980@gmail.com)
/// @dev User registry contract. Depends on a 'UserDatabase' contract.
/// Base contract for administrated user accounts. The admin can remove users and edit their data.
contract AbstractSingleAdminUserRegistry is UserRegistry, DefaultDougEnabled, Errors {

    address _admin;
    UserDatabase _udb;

    function AbstractSingleAdminUserRegistry(address dbAddress, address admin) {
        _udb = UserDatabase(dbAddress);
        _admin = admin;
    }

    /// @notice AbstractSingleAdminUserRegistry.registerUser(addr, nickname, dataHash) to register a new user.
    /// @dev Register a new user. Must be 'admin'.
    /// @param addr (address) the address.
    /// @param nickname (bytes32) the user nick.
    /// @param dataHash (bytes32) hash of the file containing user data.
    /// @return error (uint16) error code.
    function registerUser(address addr, bytes32 nickname, bytes32 dataHash) returns (uint16 error) {
        if (msg.sender != _admin)
            return ACCESS_DENIED;
        if (addr == 0 || nickname == 0)
            return NULL_PARAM_NOT_ALLOWED;
        return _udb.registerUser(addr, nickname, block.timestamp, dataHash);
    }

    /// @notice AbstractSingleAdminUserRegistry.removeUser(addr) to remove a user. Requires administrator permissions.
    /// @dev Remove a user. Must be 'admin'.
    /// @param addr (address) the address.
    /// @return error (uint16) error code.
    function removeUser(address addr) returns (uint16 error) {
        if (msg.sender != _admin && msg.sender != addr)
            return ACCESS_DENIED;
        if (addr == 0)
            return NULL_PARAM_NOT_ALLOWED;
        return _udb.removeUser(addr);
    }

    /// @notice AbstractSingleAdminUserRegistry.removeSelf() to remove yourself as a user.
    /// @dev Remove yourself as a user.
    /// @return error (uint16) error code.
    function removeSelf() returns (uint16 error) {
        return _udb.removeUser(msg.sender);
    }

    /// @notice AbstractSingleAdminUserRegistry.updateDataHash(addr, dataHash) to register a new data-hash.
    /// @dev Register a new data-hash.
    /// @param addr (address) the address.
    /// @param dataHash (bytes32) hash of the file containing user data.
    /// @return error (uint16) error code.
    function updateDataHash(address addr, bytes32 dataHash) returns (uint16 error) {
        if (msg.sender != _admin)
            return ACCESS_DENIED;
        if (addr == 0)
            return NULL_PARAM_NOT_ALLOWED;
        return _udb.updateDataHash(addr, dataHash);
    }

    /// @notice AbstractSingleAdminUserRegistry.updateMyDataHash(dataHash) to register a new data-hash for yourself.
    /// @dev Register a new data-hash for yourself.
    /// @param dataHash (bytes32) hash of the file containing user data.
    /// @return error (uint16) error code.
    function updateMyDataHash(bytes32 dataHash) returns (uint16 error) {
        return _udb.updateDataHash(msg.sender, dataHash);
    }

    /// @notice AbstractSingleAdminUserRegistry.destroy() to destroy the contract.
    /// @dev Destroy a contract. Calls 'selfdestruct' if caller is Doug.
    /// @param fundReceiver (address) the account that receives the funds.
    function destroy(address fundReceiver) {
        if (msg.sender == address(_DOUG))
            selfdestruct(fundReceiver);
    }

    /// @notice AbstractSingleAdminUserRegistry.setUserDatabase(addr) to set the address of the user database.
    /// @dev Set the address of the user database. Can only be done by 'admin'.
    /// @param dbAddr (address) the database address.
    /// @return error (uint16) error code
    function setUserDatabase(address dbAddr) returns (uint16 error) {
        if (msg.sender != _admin)
            return ACCESS_DENIED;
        _udb = UserDatabase(dbAddr);
    }

}