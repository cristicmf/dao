/// @title Permission
/// @author Andreas Olofsson (androlo1980@gmail.com)
/// @dev Interface for a simple permissions contract with a root and any number of owners.
contract Permission {

    // TODO this should really be two interfaces.

    /// @notice Permission.setRoot(newRoot) to set the root account address.
    /// @dev Set the root account address.
    /// @param newRoot (address) the address
    /// @return error (uint16) error code
    function setRoot(address newRoot) constant returns (uint16 error);

    /// @notice Permission.root() to get the root address.
    /// @dev Get the root address.
    /// @return root (address) the address of root.
    function root() constant returns (address root);

    /// @notice Permission.rootData() to get the address of root, and the time they were added.
    /// @dev Get the address of root, and the time they were created.
    /// @return root (address) the address|
    /// @return timeRootAdded (uint) the time when root was added.
    function rootData() constant returns (address root, uint timeRootAdded);

    /// @notice Permission.addOwner(addr) to add a new owner.
    /// @dev Add a new owner.
    /// @param addr (address) the address of the new owner
    /// @return error (uint16) error code
    function addOwner(address addr) returns (uint16 error);

    /// @notice Permission.removeOwner(addr) to remove an owner.
    /// @dev Remove an owner.
    /// @param addr (address) the address of the owner
    /// @return error (uint16) error code
    function removeOwner(address addr) returns (uint16 error);

    /// @notice Permission.ownerTimestamp(addr) to get the time when the owner was added.
    /// @dev Get the time when the owner was added.
    /// @param addr (address) the owner address
    /// @return timestamp (uint) the time when the owner was added|
    /// @return error (uint16) error code
    function ownerTimestamp(address addr) constant returns (uint timestamp, uint16 error);

    /// @notice Permission.ownerFromIndex(index) to get the owner with position 'index' in the backing array.
    /// @dev Get the owner with position 'index' in the backing array.
    /// @param index (uint) the index.
    /// @return owner (address) the owner address|
    /// @return timestamp (uint) the time when the owner was added|
    /// @return error (uint16) error code
    function ownerFromIndex(uint index) constant returns (address owner, uint timestamp, uint16 error);

    /// @notice Permission.numOwners() to get the total number of owners.
    /// @dev Get the total number of owners.
    /// @return numOwners (uint) the number of owners
    function numOwners() constant returns (uint numOwners);

    /// @notice Permission.hasPermission(addr) to check if an address has this permission.
    /// @dev Check if an address has this permission.
    /// @param addr (address) the address
    /// @return hasPerm (bool) true if the address is either root or an owner, false otherwise.
    function hasPermission(address addr) constant returns (bool hasPerm);

}