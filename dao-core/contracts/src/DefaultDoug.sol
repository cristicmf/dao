import "../../../dao-stl/src/errors/Errors.sol";
import {Doug, DougEnabled, Destructible} from "./Doug.sol";
import "./Permission.sol";

/// @title DefaultDoug
/// @author Andreas Olofsson (androlo1980@gmail.com)
/// @dev Default implementation of the 'Doug' interface-contract.
/// Most collections work is done internally, rather then through a library.
/// Method documentation is in the 'Doug' interface contract.
contract DefaultDoug is Doug, Errors {

    address constant ADDRESS_NULL = 0;
    bytes32 constant BYTES32_NULL = 0;

    bool _destroyRemovedActions;
    bool _destroyRemovedDatabases;

    Permission _permission;

    // Element used in NAMap.
    struct NAElement {
        uint _keyIndex;
        address value;
    }

    // Map that stores id<->address mappings. Can be iterated over.
    struct NAMap
    {
        mapping(address => bytes32) _aToN;
        mapping(bytes32 => NAElement) _data;
        bytes32[] _keys;
    }

    NAMap _aMap;
    NAMap _dMap;

    // Constructor
    function DefaultDoug(address permissionAddress, bool destroyActions, bool destroyDatabases) {
        _permission = Permission(permissionAddress);
        _destroyRemovedActions = destroyActions;
        _destroyRemovedDatabases = destroyDatabases;
    }

    // *********************************** Actions contracts ************************************

    /// @notice DefaultDoug.addActionsContract(identifier, contractAddress) to add a new contract to the registry.
    /// @dev Add a new contract to the registry. Fires off 'ActionsContractAdded' event if successful.
    /// @param identifier (bytes32) the identifier (name)
    /// @param contractAddress (address) the contract address
    /// @return error (uint16) an error code
    function addActionsContract(bytes32 identifier, address contractAddress) external returns (uint16 error) {
        error = _addContract(_aMap, identifier, contractAddress);
        if (error == NO_ERROR)
            ActionsContractAdded(identifier, contractAddress);
    }

    /// @notice DefaultDoug.removeActionsContract(identifier) to remove a contract from the registry.
    /// @dev Remove a contract from the registry. Fires an 'ActionsContractRemoved' event if successful.
    /// Will also invoke 'Destructible.destroy' on the contract if automatic destruction on removal is set.
    /// @param identifier (bytes32) the identifier (name)
    /// @return error (uint16) an error code
    function removeActionsContract(bytes32 identifier) external returns (uint16 error) {
        var (addr, err) = _removeContract(_aMap, identifier);
        if (err == NO_ERROR) {
            ActionsContractRemoved(identifier, addr);
            if (_destroyRemovedActions)
                Destructible(addr).destroy(_permission.root());
        }
        return err;
    }

    /// @notice DefaultDoug.actionsContractAddress(identifier) to get the address of the contract with the given id.
    /// @dev Get the address of the contract with the given Id.
    /// @param identifier (bytes32) the identifier (name)
    /// @return contractAddress (address) the address (or nil)
    function actionsContractAddress(bytes32 identifier) constant returns (address contractAddress) {
         return _aMap._data[identifier].value;
    }

    /// @notice DefaultDoug.actionsContractId(address) to get the id of the contract with the given address.
    /// @dev Get the id of the contract with the given address.
    /// @param contractAddress (address) the contract address
    /// @return identifier (bytes32) the id (or nil)
    function actionsContractId(address contractAddress) constant returns (bytes32 identifier) {
         return _aMap._aToN[contractAddress];
    }

    /// @notice DefaultDoug.actionsContractFromIndex(index) to get the id and address of the contract with the given index.
    /// @dev Get the id and address of the contract with the given index.
    /// @param index (uint) the index
    /// @return identifier (bytes32) the id|
    /// @return contractAddress (bytes32) the address|
    /// @return error (uint16) error code
    function actionsContractFromIndex(uint index) constant returns (bytes32 identifier, address contractAddress, uint16 error) {
        return _contractFromIndex(_aMap, index);
    }

    /// @notice DefaultDoug.numActionsContracts() to get the number of contracts in the registry.
    /// @dev Get the number of contracts in the registry
    /// @return numContracts (uint) the number of contracts
    function numActionsContracts() constant returns (uint numContracts) {
        return _aMap._keys.length;
    }

    /// @notice DefaultDoug.setDestroyRemovedActions(destroyRemovedActions) to
    /// set if 'destroy' should be called automatically when a contract is removed.
    /// @dev Enable to call 'destroy' method on contracts.
    /// when they are removed.
    /// @param destroyRemovedActions (bool) whether or not contracts should be overwritable
    /// @return error (uint16) error code
    function setDestroyRemovedActions(bool destroyRemovedActions) returns (uint16 error) {
        if (!_hasDougPermission())
            return ACCESS_DENIED;
        _destroyRemovedActions = destroyRemovedActions;
    }

    /// @notice DefaultDoug.destroyRemovedActions() to check if contracts are automatically destroyed when removed.
    /// @dev Check if contracts are automatically destroyed when removed
    /// @return destroyRemovedActions (bool) whether or not 'destroy' should be called on contracts
    /// when they are removed.
    function destroyRemovedActions() constant returns (bool destroyRemovedActions) {
        return _destroyRemovedActions;
    }

    // *********************************** Database contracts ************************************

    /// @notice DefaultDoug.addDatabaseContract(identifier, contractAddress) to add a new contract to the registry.
    /// @dev Add a new contract to the registry. Fires off 'DatabaseContractAdded' event if successful.
    /// @param identifier (bytes32) the identifier (name)
    /// @param contractAddress (address) the contract address
    /// @return error (uint16) an error code
    function addDatabaseContract(bytes32 identifier, address contractAddress) external returns (uint16 error) {
        error = _addContract(_dMap, identifier, contractAddress);
        if (error == NO_ERROR)
            DatabaseContractAdded(identifier, contractAddress);
    }

    /// @notice DefaultDoug.removeDatabaseContract(identifier) to remove a contract from the registry.
    /// @dev Remove a contract from the registry. Fires off 'DatabaseContractRemoved' event if successful.
    /// Will also invoke 'Destructible.destroy' on the contract if automatic destruction on removal is set.
    /// @param identifier (bytes32) the identifier (name)
    /// @return error (uint16) an error code
    function removeDatabaseContract(bytes32 identifier) external returns (uint16 error) {
        var (addr, err) = _removeContract(_dMap, identifier);
        if (err == NO_ERROR) {
            DatabaseContractRemoved(identifier, addr);
            if (_destroyRemovedDatabases)
                Destructible(addr).destroy(_permission.root());
        }
        return err;
    }

    /// @notice DefaultDoug.databaseContractAddress(identifier) to get the address of the contract with the given id.
    /// @dev Get the address of the contract with the given Id.
    /// @param identifier (bytes32) the identifier (name)
    /// @return contractAddress (address) the address (or nil)
    function databaseContractAddress(bytes32 identifier) constant returns (address contractAddress) {
         return _dMap._data[identifier].value;
    }

    /// @notice DefaultDoug.databaseContractId(address) to get the id of the contract with the given address.
    /// @dev Get the id of the contract with the given address.
    /// @param contractAddress (address) the contract address
    /// @return identifier (bytes32) the id (or nil)
    function databaseContractId(address contractAddress) constant returns (bytes32 identifier) {
         return _dMap._aToN[contractAddress];
    }

    /// @notice DefaultDoug.databaseContractFromIndex(index) to get the id and address of the contract with the given index.
    /// @dev Get the id and address of the contract with the given index.
    /// @param index (uint) the index
    /// @return identifier (bytes32) the id|
    /// @return contractAddress (bytes32) the address|
    /// @return error (uint16) error code
    function databaseContractFromIndex(uint index) constant returns (bytes32 identifier, address contractAddress, uint16 error) {
        return _contractFromIndex(_dMap, index);
    }

    /// @notice DefaultDoug.numDatabaseContracts() to get the number of contracts in the registry.
    /// @dev Get the number of contracts in the registry.
    /// @return numContracts (uint) the number of contracts
    function numDatabaseContracts() constant returns (uint numContracts) {
        return _dMap._keys.length;
    }

    /// @notice DefaultDoug.setDestroyRemovedDatabases(destroyRemovedDatabases) to
    /// set if 'destroy' should be called automatically when a contract is removed.
    /// @dev Enable to call 'destroy' method on contracts.
    /// when they are removed.
    /// @param destroyRemovedDatabases (bool) whether or not contracts should be destroyed when removed
    /// @return error (uint16) error code
    function setDestroyRemovedDatabases(bool destroyRemovedDatabases) returns (uint16 error) {
        if (!_hasDougPermission())
            return ACCESS_DENIED;
        _destroyRemovedDatabases = destroyRemovedDatabases;
    }

    /// @notice DefaultDoug.destroyRemovedDatabases() to check if contracts are automatically destroyed when removed.
    /// @dev Check if contracts are automatically destroyed when removed
    /// @return destroyRemovedDatabases (bool) whether or not 'destroy' should be called on contracts
    /// when they are removed.
    function destroyRemovedDatabases() constant returns (bool destroyRemovedDatabases) {
        return _destroyRemovedDatabases;
    }

    // *********************************** Doug specific ************************************

    /// @notice DefaultDoug.setPermission(permissionAddress) to set the permission contract address.
    /// @dev Set the permission contract address;
    /// @param permissionAddress (address) the address to the permission contract.
    /// @return error (uint16) error code
    function setPermission(address permissionAddress) returns (uint16 error) {
        // Only allow
        if (address(_permission) != ADDRESS_NULL && msg.sender != _permission.root())
            return ACCESS_DENIED;
        _permission = Permission(permissionAddress);
    }

    /// @notice DefaultDoug.permissionsManager() to get the address of the permissions-manager.
    /// @dev Get the address of the permission contract.
    /// @return pmAddress (address) the address
    function permissionAddress() constant returns (address pmAddress) {
        return _permission;
    }

    /// @notice DefaultDoug.destroy() to destroy the contract.
    /// @dev Calls 'selfdestruct' if caller is the account set as permission root.
    /// on the contract if successful.
    /// @param fundReceiver (address) the account that receives the funds.
    function destroy(address fundReceiver) {
        if (msg.sender == _permission.root())
            selfdestruct(fundReceiver);
    }

    // *********************************** Internal ************************************

    // Add a contract to the given map.
    function _addContract(NAMap storage map, bytes32 identifier, address contractAddress) internal returns (uint16 error) {
        if (!_hasDougPermission()) {
            error = ACCESS_DENIED;
            return;
        }
        // Neither the ID nor the address can be null.
        if (identifier == BYTES32_NULL || contractAddress == ADDRESS_NULL) {
            error = NULL_PARAM_NOT_ALLOWED;
            return;
        }

        var oldAddress = map._data[identifier].value;
        var exists = oldAddress != ADDRESS_NULL;
        if (exists) {
            error = RESOURCE_ALREADY_EXISTS;
            return;
        }

        bool sda = DougEnabled(contractAddress).setDougAddress(this);

        // If failing the doug-address check - break.
        if (!sda) {
            // Come up with something better here.
            error = PARAMETER_ERROR;
            return;
        }
        // Register address under the given ID.
        if (!exists) {
            var keyIndex = map._keys.length++;
            map._keys[keyIndex] = identifier;
            map._data[identifier] = NAElement(keyIndex, contractAddress);
        }
        else
            map._data[identifier].value = contractAddress;
        // Register ID under the given address.
        map._aToN[contractAddress] = identifier;
    }

    // Remove a contract from the given map.
    function _removeContract(NAMap storage map, bytes32 identifier) internal returns (address addr, uint16 error) {
        if (!_hasDougPermission()) {
            error = ACCESS_DENIED;
            return;
        }
        if (identifier == BYTES32_NULL) {
            error = NULL_PARAM_NOT_ALLOWED;
            return;
        }
        var elem = map._data[identifier];
        addr = elem.value;
        var exists = addr != ADDRESS_NULL;
        if (!exists) {
            error = RESOURCE_NOT_FOUND;
            return;
        }
        var keyIndex = elem._keyIndex;
        delete map._data[identifier];
        delete map._aToN[addr];
        var len = map._keys.length;
        if (keyIndex != len - 1) {
            var swap = map._keys[len - 1];
            map._keys[keyIndex] = swap;
            map._data[swap]._keyIndex = keyIndex;
        }
        map._keys.length--;
    }

    // Get a contract by index, from the given map.
    function _contractFromIndex(NAMap storage map, uint index) internal constant returns (bytes32 identifier, address contractAddress, uint16 error) {
        if (index >= map._keys.length) {
            error = ARRAY_INDEX_OUT_OF_BOUNDS;
            return;
        }
        identifier = map._keys[index];
        contractAddress = map._data[identifier].value;
    }

    // Check if the caller has doug permissions.
    function _hasDougPermission() constant internal returns (bool isRoot) {
        return address(_permission) != 0 && _permission.hasPermission(msg.sender);
    }

}