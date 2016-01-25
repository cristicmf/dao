import "../../../dao-core/contracts/src/Doug.sol";

/// @title UserRegistry
/// @author Andreas Olofsson (androlo1980@gmail.com)
/// @dev A contract that works with a user database to register and manage users.
contract UserRegistry is DougEnabled {

    /// @notice UserRegistry.registerUser(addr, nickname, dataHash) to register a new user.
    /// @dev Register a new user.
    /// @param addr (address) the address.
    /// @param nickname (bytes32) the user nick.
    /// @param dataHash (bytes32) hash of the file containing user data.
    /// @return error (uint16) error code.
    function registerUser(address addr, bytes32 nickname, bytes32 dataHash) returns (uint16 error);

    /// @notice UserRegistry.registerSelf(nickname, dataHash) to register a new user.
    /// @dev Register a new user.
    /// @param nickname (bytes32) the user nick.
    /// @param dataHash (bytes32) hash of the file containing user data.
    /// @return error (uint16) error code.
    function registerSelf(bytes32 nickname, bytes32 dataHash) returns (uint16 error);

    /// @notice UserRegistry.removeUser(addr) to remove a user. Requires administrator permissions.
    /// @dev Remove a user.
    /// @param addr (address) the address.
    /// @return error (uint16) error code.
    function removeUser(address addr) returns (uint16 error);

    /// @notice UserRegistry.removeSelf() to remove yourself as a user.
    /// @dev Remove yourself as a user.
    /// @return error (uint16) error code.
    function removeSelf() returns (uint16 error);

    /// @notice UserRegistry.updateDataHash(addr, dataHash) to register a new data-hash.
    /// @dev Register a new data-hash.
    /// @param addr (address) the address.
    /// @param dataHash (bytes32) hash of the file containing user data.
    /// @return error (uint16) error code.
    function updateDataHash(address addr, bytes32 dataHash) returns (uint16 error);

    /// @notice UserRegistry.updateMyDataHash(dataHash) to register a new data-hash for yourself.
    /// @dev Register a new data-hash for yourself.
    /// @param dataHash (bytes32) hash of the file containing user data.
    /// @return error (uint16) error code.
    function updateMyDataHash(bytes32 dataHash) returns (uint16 error);

    /// @notice UserRegistry.setUserDatabase(addr) to set the address of the user database.
    /// @dev Set the address of the user database.
    /// @param dbAddr (address) the database address.
    /// @return error (uint16) error code
    function setUserDatabase(address dbAddr) returns (uint16 error);

    /// @notice UserRegistry.userDatabase() to get the address of the user database.
    /// @dev Get the address of the user database.
    /// @return dbAddr (address) the database address.
    function userDatabase() returns (address dbAddr);

}