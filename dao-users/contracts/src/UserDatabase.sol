import "../../../dao-core/contracts/src/Doug.sol";

/// @title UserDatabase
/// @author Andreas Olofsson (androlo1980@gmail.com)
/// @dev UserDatabase keeps an iterable record of users.
/// User data needs to contain:
/// 'nickname' (bytes32) - a user nick.
/// 'timestamp' (uint) - the (unix) time when the user was added.
/// 'dataHash' (bytes32) - preferably a reference to a file (e.g. bittorent, ipfs, etc.).
contract UserDatabase is DougEnabled {

    /// @notice UserDatabase.registerUser(addr, value_nickname, value_timestamp, value_dataHash) to register a new user. Overwriting not allowed.
    /// @dev Register a new user.
    /// @param addr (address) the address.
    /// @param value_nickname (bytes32) the user name.
    /// @param value_timestamp (uint) the unix timestamp.
    /// @param value_dataHash (bytes32) hash of the file containing (optional) user data.
    /// @return error (uint16) error code.
    function registerUser(address addr, bytes32 value_nickname, uint value_timestamp, bytes32 value_dataHash) returns (uint16 error);

    /// @notice UserDatabase.updateDataHash(addr, dataHash) to register a new data-hash for a user.
    /// @dev Register a new data hash for a user.
    /// @param addr (address) the address.
    /// @param dataHash (bytes32) hash of the file containing user data.
    /// @return error (uint16) error code.
    function updateDataHash(address addr, bytes32 dataHash) returns (uint16 error);

    /// @notice UserDatabase.removeUser(addr) to remove a user.
    /// @dev Remove a user.
    /// @param addr (address) the user address.
    /// @return error (uint16) error code.
    function removeUser(address addr) returns (uint16 error);

    /// @notice UserDatabase.user(addr) to get user data.
    /// @dev Get user data.
    /// @param addr (address) the address.
    /// @return value_nickname (bytes32) the nickname.
    /// @return value_timestamp (uint) the time when the user was added.
    /// @return value_dataHash (bytes32) the data-hash (optional).
    function user(address addr) constant returns (bytes32 value_nickname, uint value_timestamp, bytes32 value_dataHash);

    /// @notice UserDatabase.hasUser(addr) to check if a user exists.
    /// @dev Check if a user exists.
    /// @param addr (address) the address.
    /// @return has (bool) whether or not the user exists.
    function hasUser(address addr) constant returns (bool has);

    /// @notice UserDatabase.hasUsers(addr1, addr2) to check if two users exists.
    /// Convenience function for user-to-user interaction checks.
    /// @dev Check if two users exists.
    /// @param addr1 (address) the address of the first user.
    /// @param addr2 (address) the address of the second user.
    /// @return has1 (bool) whether or not the first user exists.
    /// @return has2 (bool) whether or not the second user exists.
    function hasUsers(address addr1, address addr2) constant returns (bool has1, bool has2);

    /// @notice UserDatabase.userAddressFromIndex(index) to get a user address by its index in the backing array.
    /// @dev Get a user address by its index in the backing array.
    /// @param index (uint) the index.
    /// @return key (address) the key.
    /// @return error (uint16) error code.
    function userAddressFromIndex(uint index) constant returns (address addr, uint16 error);

    /// @notice UserDatabase.size() to get the number of users.
    /// @dev Get the number of users.
    /// @return size (uint) the number of users.
    function size() constant returns (uint size);

}