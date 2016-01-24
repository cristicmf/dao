import "./Permission.sol";

/// @title Destructible
/// @author Andreas Olofsson (andolo1980@gmail.com)
/// @dev Interface for destroying (deleting) a contract.
/// Should be implemented by contracts that are used as doug actions or
/// database contracts, so that the contract can be automatically
/// destroyed when it is removed from Doug.
contract Destructible {
    /// @notice Destructible.destroy() to destroy the contract.
    /// @dev Destroy a contract. No return values since it's a destruction.
    /// @param fundReceiver (address) the account that receives the funds.
    function destroy(address fundReceiver);
}


/// @title DougEnabled
/// @author Andreas Olofsson (andolo1980@gmail.com)
/// @dev Interface must be implemented by contracts that are used as doug
/// actions or database contracts.
contract DougEnabled is Destructible {

    /// @notice DougEnabled.setDougAddress(dougAddress) to set the address of the Doug contract.
    /// @dev Set the address of the Doug contract.
    /// @param dougAddr (address) the address
    /// @return added (bool) true means the address was added successfully (doug implementations
    /// should normally not register a contract that returns false.
    function setDougAddress(address dougAddr) returns (bool result);

    /// @notice DougEnabled.getDougAddress() to get the address of the Doug contract.
    /// @dev Get the address of the Doug contract.
    /// @return dougAddress (address) the doug address.
    function dougAddress() constant returns (address dougAddress);

}


/// @title ActionsContractRegistry
/// @author Andreas Olofsson (androlo1980@gmail.com)
/// @dev ActionsContractRegistry has a registry for actions contracts.
contract ActionsContractRegistry {

    /// @dev fired when a new contract is added to Doug.
    /// @param contractId (bytes32) the id of the contract
    /// @param contractId (address) the address of the contract
    event ActionsContractAdded(bytes32 indexed contractId, address indexed contractAddress);

    /// @dev fired when a contract is removed from Doug.
    /// @param contractId (bytes32) the id of the contract
    /// @param contractId (address) the address of the contract
    event ActionsContractRemoved(bytes32 indexed contractId, address indexed contractAddress);

    /// @notice ActionsContractRegistry.addActionsContract(identifier, contractAddress) to add a new contract to the registry.
    /// @dev Add a new contract to the registry.
    /// @param identifier (bytes32) the identifier (name)
    /// @param contractAddress (address) the contract address
    /// @return error (uint16) an error code
    function addActionsContract(bytes32 identifier, address contractAddress) external returns (uint16 error);

    /// @notice ActionsContractRegistry.removeActionsContract(identifier) to remove a contract from the registry.
    /// @dev Remove a contract from the registry.
    /// @param identifier (bytes32) the identifier (name)
    /// @return error (uint16) an error code
    function removeActionsContract(bytes32 identifier) external returns (uint16 error);
    
    /// @notice ActionsContractRegistry.actionsContractAddress(identifier) to get the address of the contract with the given id.
    /// @dev Get the address of the contract with the given Id.
    /// @param identifier (bytes32) the identifier (name)
    /// @return contractAddress (address) the address (or nil)
    function actionsContractAddress(bytes32 identifier) constant returns (address contractAddress);

    /// @notice ActionsContractRegistry.actionsContractId(address) to get the id of the contract with the given address.
    /// @dev Get the id of the contract with the given address.
    /// @param contractAddress (address) the contract address
    /// @return identifier (bytes32) the id (or nil)
    function actionsContractId(address contractAddress) constant returns (bytes32 identifier);

    /// @notice ActionsContractRegistry.actionsContractFromIndex(index) to get the id and address of the contract with the given index.
    /// @dev Get the id and address of the contract with the given index.
    /// @param index (uint) the index
    /// @return identifier (bytes32) the id|
    /// @return contractAddress (bytes32) the address|
    /// @return error (uint16) error code
    function actionsContractFromIndex(uint index) constant returns (bytes32 identifier, address contractAddress, uint16 error);

    /// @notice ActionsContractRegistry.numActionsContracts() to get the number of contracts in the registry.
    /// @dev Get the number of contracts in the registry
    /// @return numContracts (uint) the number of contracts
    function numActionsContracts() constant returns (uint numContracts);

    /// @notice ActionsContractRegistry.setDestroyRemovedActions(destroyRemovedActions) to
    /// set if 'destroy' should be called automatically when a contract is removed.
    /// @dev Enable to call 'destroy' method on contracts.
    /// when they are removed.
    /// @param destroyRemovedActions (bool) whether or not contracts should be overwritable
    /// @return error (uint16) error code
    function setDestroyRemovedActions(bool destroyRemovedActions) returns (uint16 error);

    /// @notice ActionsContractRegistry.destroyRemovedActions() to check if contracts are automatically destroyed when removed.
    /// @dev Check if contracts are automatically destroyed when removed
    /// @return destroyRemovedActions (bool) whether or not 'destroy' should be called on contracts
    /// when they are removed.
    function destroyRemovedActions() constant returns (bool destroyRemovedActions);

}


/// @title DatabaseContractRegistry
/// @author Andreas Olofsson (androlo1980@gmail.com)
/// @dev DatabaseContractRegistry has a registry for database contracts.
contract DatabaseContractRegistry {

    /// @dev fired when a new database contract is added to Doug.
    /// @param contractId (bytes32) the id of the contract
    /// @param contractId (address) the address of the contract
    event DatabaseContractAdded(bytes32 indexed contractId, address indexed contractAddress);

    /// @dev fired when a database contract is removed from Doug.
    /// @param contractId (bytes32) the id of the contract
    /// @param contractId (address) the address of the contract
    event DatabaseContractRemoved(bytes32 indexed contractId, address indexed contractAddress);

    /// @notice DatabaseContractRegistry.addDatabaseContract(identifier, contractAddress) to add a new contract to the registry.
    /// @dev Add a new contract to the registry.
    /// @param identifier (bytes32) the identifier (name)
    /// @param contractAddress (address) the contract address
    /// @return error (uint16) an error code
    function addDatabaseContract(bytes32 identifier, address contractAddress) external returns (uint16 error);

    /// @notice DatabaseContractRegistry.removeDatabaseContract(identifier) to remove a contract from the registry.
    /// @dev Remove a contract from the registry.
    /// @param identifier (bytes32) the identifier (name)
    /// @return error (uint16) an error code
    function removeDatabaseContract(bytes32 identifier) external returns (uint16 error);

    /// @notice DatabaseContractRegistry.databaseContractAddress(identifier) to get the address of the contract with the given id.
    /// @dev Get the address of the contract with the given Id.
    /// @param identifier (bytes32) the identifier (name)
    /// @return contractAddress (address) the address (or nil)
    function databaseContractAddress(bytes32 identifier) constant returns (address contractAddress);

    /// @notice DatabaseContractRegistry.databaseContractId(address) to get the id of the contract with the given address.
    /// @dev Get the id of the contract with the given address.
    /// @param contractAddress (address) the contract address
    /// @return identifier (bytes32) the id (or nil)
    function databaseContractId(address contractAddress) constant returns (bytes32 identifier);

    /// @notice DatabaseContractRegistry.databaseContractFromIndex(index) to get the id and address of the contract with the given index.
    /// @dev Get the id and address of the contract with the given index.
    /// @param index (uint) the index
    /// @return identifier (bytes32) the id|
    /// @return contractAddress (bytes32) the address|
    /// @return error (uint16) error code
    function databaseContractFromIndex(uint index) constant returns (bytes32 identifier, address contractAddress, uint16 error);

    /// @notice DatabaseContractRegistry.numDatabaseContracts() to get the number of contracts in the registry.
    /// @dev Get the number of contracts in the registry.
    /// @return numContracts (uint) the number of contracts
    function numDatabaseContracts() constant returns (uint numContracts);

    /// @notice DatabaseContractRegistry.setDestroyRemovedDatabases(destroyRemovedDatabases) to
    /// set if 'destroy' should be called automatically when a contract is removed.
    /// @dev Enable to call 'destroy' method on contracts.
    /// when they are removed.
    /// @param destroyRemovedDatabases (bool) whether or not contracts should be destroyed when removed
    /// @return error (uint16) error code
    function setDestroyRemovedDatabases(bool destroyRemovedDatabases) returns (uint16 error);

    /// @notice DatabaseContractRegistry.destroyRemovedDatabases() to check if contracts are automatically destroyed when removed.
    /// @dev Check if contracts are automatically destroyed when removed
    /// @return destroyRemovedDatabases (bool) whether or not 'destroy' should be called on contracts
    /// when they are removed.
    function destroyRemovedDatabases() constant returns (bool destroyRemovedDatabases);

}


// TODO other options.
/// @title Doug
/// @author Andreas Olofsson (androlo1980@gmail.com)
/// @dev Doug is the top level contract in a DApp. It has registries for contracts and a
/// permissions manager.
/// Contract IDs are 32 byte strings (bytes32).
/// Contracts are registered using a bi-directional bytes32<->address map, and can be referenced
/// either by ID or address.
/// Contracts can only be given one (unique) ID, however the ID of a specific contract
/// can be changed later, provided that the new ID isn't taken, and the 'overwritable' option is set.
contract Doug is ActionsContractRegistry, DatabaseContractRegistry, Destructible {

    /// @notice Doug.setPermission(permissionAddress) to set the permission contract address.
    /// @dev Set the permission contract address;
    /// @param permissionAddress (address) the address to the permission contract.
    /// @return error (uint16) error code
    function setPermission(address permissionAddress) returns (uint16 error);

    /// @notice Doug.permissionsManager() to get the address of the permissions-manager.
    /// @dev Get the address of the permissions-manager.
    /// @return pmAddress (address) the address
    function permissionAddress() constant returns (address pmAddress);

}


/// @title DefaultDougEnabled
/// @author Andreas Olofsson (androlo1980@gmail.com)
/// @dev Default implementation of 'DougEnabled'.
contract DefaultDougEnabled is DougEnabled {

    Doug _DOUG;

    function setDougAddress(address dougAddr) returns (bool result) {
        // If dougAddr is zero.
        if (dougAddr == 0)
            return false;
        // If Doug is set, only change it if the caller is the current Doug.
        if(address(_DOUG) != 0x0 && address(_DOUG) != msg.sender)
            return false;
        _DOUG = Doug(dougAddr);
        return true;
    }

    function dougAddress() constant returns (address dougAddress) {
        return _DOUG;
    }

}