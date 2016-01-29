import "../../../dao-stl/contracts/src/errors/Errors.sol";
import "./Doug.sol";
import "./Permission.sol";

/*
    Interface: DefaultDoug

    Default implementation of the 'Doug' interface-contract.

    Contracts are registered using a bi-directional bytes32<->address map, and can be referenced
    either by ID or by address. There is also an array of IDs that enables iteration.

    Adding, removing and getting contracts from the registries are all O(1).

    Contracts can only be given one id, and each id is unique.

    Most collections work is done internally rather then through a library.

    Author: Andreas Olofsson (androlo1980@gmail.com)
*/
contract DefaultDoug is Doug, Errors {

    address constant ADDRESS_NULL = 0;
    bytes32 constant BYTES32_NULL = 0;

    bool _destroyRemovedActions;
    bool _destroyRemovedDatabases;

    Permission _permission;

    /*
        Struct: NAElement

        Element type for NAMap
    */
    struct NAElement {
        uint _keyIndex;
        address value;
    }

    /*
        Struct: NAMap

        Keeps bi-directoinal mappings between contract ids (bytes32) and addresses.
        Also keeps an array of all ids for iteration.
    */
    struct NAMap
    {
        mapping(address => bytes32) _aToN;
        mapping(bytes32 => NAElement) _data;
        bytes32[] _keys;
    }

    NAMap _aMap;
    NAMap _dMap;

    /*
        Constructor:  DefaultDoug

        Check if the caller is registered as an actions contract in doug.

        Params:
            permissionAddress (address) - The address to the permission contract.
            destroyActions (bool) - Whether or not actions-contracts should be destroyed when removed.
            destroyDatabases (bool) - Whether or not database-contracts should be destroyed when removed.

    */
    function DefaultDoug(address permissionAddress, bool destroyActions, bool destroyDatabases) {
        _permission = Permission(permissionAddress);
        _destroyRemovedActions = destroyActions;
        _destroyRemovedDatabases = destroyDatabases;
    }

    // *********************************** Actions contracts ************************************

    /*
        Function: addActionsContract

        Add a new contract to the registry.

        Fires off an <ActionsContractRegistry.ActionsContractAdded> event if successful.

        Params:
            identifier (bytes32) - The identifier (name).
            contractAddress (address) - The contract address.

        Returns:
            error (uint16) - An error code.
    */
    function addActionsContract(bytes32 identifier, address contractAddress) external returns (uint16 error) {
        error = _addContract(_aMap, identifier, contractAddress);
        if (error == NO_ERROR)
            ActionsContractAdded(identifier, contractAddress);
    }

    /*
        Function: removeActionsContract

        Remove a contract from the registry.

        Fires off an <ActionsContractRegistry.ActionsContractRemoved> event if successful.

        Params:
            identifier (bytes32) - The identifier (name).

        Returns:
            error (uint16) - An error code.
    */
    function removeActionsContract(bytes32 identifier) external returns (uint16 error) {
        var (addr, err) = _removeContract(_aMap, identifier);
        if (err == NO_ERROR) {
            ActionsContractRemoved(identifier, addr);
            if (_destroyRemovedActions)
                Destructible(addr).destroy(_permission.root());
        }
        return err;
    }

    /*
        Function: actionsContractAddress

        Get the address of the contract with the given id.

        Params:
            identifier (bytes32) - The identifier (name).

        Returns:
            contractAddress (address) - The address (can be null).
    */
    function actionsContractAddress(bytes32 identifier) constant returns (address contractAddress) {
         return _aMap._data[identifier].value;
    }

    /*
        Function: actionsContractId

        Get the id of the contract with the given address.

        Params:
            contractAddress (address) - The contract address.

        Returns:
            identifier (bytes32) - The id (can be null).
    */
    function actionsContractId(address contractAddress) constant returns (bytes32 identifier) {
         return _aMap._aToN[contractAddress];
    }

    /*
        Function: actionsContractFromIndex

        Get the id and address of the contract with the given index.

        Params:
            index (uint) - The index.

        Returns:
            identifier (bytes32) - The id (can be null).
            contractAddress (address) - The address (can be null).
            error (uint16) - An error code.
    */
    function actionsContractFromIndex(uint index) constant returns (bytes32 identifier, address contractAddress, uint16 error) {
        return _contractFromIndex(_aMap, index);
    }

    /*
        Function: numActionsContracts

        Get the number of contracts in the registry.

        Returns:
            numContracts (uint) - The number of actions-contracts.
    */
    function numActionsContracts() constant returns (uint numContracts) {
        return _aMap._keys.length;
    }

    /*
        Function: setDestroyRemovedActions

        Enable to call 'destroy' method on contracts.

        Params:
            destroyRemovedActions (bool) - Whether or not actions-contracts is destroyed when removed.

        Returns:
            error - (uint16) An error code.
    */
    function setDestroyRemovedActions(bool destroyRemovedActions) returns (uint16 error) {
        if (!_hasDougPermission())
            return ACCESS_DENIED;
        _destroyRemovedActions = destroyRemovedActions;
    }

    /*
        Function: destroyRemovedActions

        Check if contracts are automatically destroyed when removed.

        Returns:
            destroyRemovedActions (bool) - Whether or not actions-contracts is destroyed when removed.
    */
    function destroyRemovedActions() constant returns (bool destroyRemovedActions) {
        return _destroyRemovedActions;
    }

    // *********************************** Database contracts ************************************

    /*
        Function: addDatabaseContract

        Add a new contract to the registry.

        Fires off an <DatabaseContractRegistry.DatabaseContractAdded> event if successful.

        Params:
            identifier (bytes32) - The identifier (name).
            contractAddress (address) - The contract address.

        Returns:
            error (uint16) - An error code.
    */
    function addDatabaseContract(bytes32 identifier, address contractAddress) external returns (uint16 error) {
        error = _addContract(_dMap, identifier, contractAddress);
        if (error == NO_ERROR)
            DatabaseContractAdded(identifier, contractAddress);
    }

    /*
        Function: removeDatabaseContract

        Remove a contract from the registry.

        Fires off an <DatabaseContractRegistry.DatabaseContractRemoved> event if successful.

        Params:
            identifier (bytes32) - The identifier (name).

        Returns:
            error (uint16) - An error code.
    */
    function removeDatabaseContract(bytes32 identifier) external returns (uint16 error) {
        var (addr, err) = _removeContract(_dMap, identifier);
        if (err == NO_ERROR) {
            DatabaseContractRemoved(identifier, addr);
            if (_destroyRemovedDatabases)
                Destructible(addr).destroy(_permission.root());
        }
        return err;
    }

    /*
        Function: databaseContractAddress

        Get the address of the contract with the given id.

        Params:
            identifier (bytes32) - The identifier (name).

        Returns:
            contractAddress (address) - The address (can be null).
    */
    function databaseContractAddress(bytes32 identifier) constant returns (address contractAddress) {
         return _dMap._data[identifier].value;
    }

    /*
        Function: databaseContractId

        Get the id of the contract with the given address.

        Params:
            contractAddress (address) - The contract address.

        Returns:
            identifier (bytes32) - The id (can be null).
    */
    function databaseContractId(address contractAddress) constant returns (bytes32 identifier) {
         return _dMap._aToN[contractAddress];
    }

    /*
        Function: databaseContractFromIndex

        Get the id and address of the contract with the given index.

        Params:
            index (uint) - The index.

        Returns:
            identifier (bytes32) - The id (can be null).
            contractAddress (address) - The address (can be null).
            error (uint16) - An error code.
    */
    function databaseContractFromIndex(uint index) constant returns (bytes32 identifier, address contractAddress, uint16 error) {
        return _contractFromIndex(_dMap, index);
    }

    /*
        Function: numDatabaseContracts

        Get the number of contracts in the registry.

        Returns:
            numContracts (uint) - The number of contracts.
    */
    function numDatabaseContracts() constant returns (uint numContracts) {
        return _dMap._keys.length;
    }

    /*
        Function: setDestroyRemovedDatabases

        Enable to call 'destroy' method on contracts.

        Params:
            destroyRemovedDatabases (bool) - Whether or not database-contracts are destroyed when removed.

        Returns:
            error (uint16) - An error code.
    */
    function setDestroyRemovedDatabases(bool destroyRemovedDatabases) returns (uint16 error) {
        if (!_hasDougPermission())
            return ACCESS_DENIED;
        _destroyRemovedDatabases = destroyRemovedDatabases;
    }

    /*
        Function: destroyRemovedDatabase

        Check if contracts are automatically destroyed when removed.

        Returns:
            destroyRemovedDatabase (bool) - Whether or not database-contracts are destroyed when removed.
    */
    function destroyRemovedDatabases() constant returns (bool destroyRemovedDatabases) {
        return _destroyRemovedDatabases;
    }

    // *********************************** Doug specific ************************************

    /*
        Function: setPermission

        Set the permission contract address.

        Params:
            permissionAddress (address) - The address to the permission contract.

        Returns:
            error (uint16) - An error code.
    */
    function setPermission(address permissionAddress) returns (uint16 error) {
        // Only allow
        if (address(_permission) != ADDRESS_NULL && msg.sender != _permission.root())
            return ACCESS_DENIED;
        _permission = Permission(permissionAddress);
    }

    /*
        Function: permissionAddress

        Get the address of the permission contract.

        Params:
            permissionAddress (address) the address to the permission contract.

        Returns:
            pmAddress (address) - The address of the permissions contract.
    */
    function permissionAddress() constant returns (address pmAddress) {
        return _permission;
    }

     /*
        Function: destroy

        Destroys the contract if the caller has root permission.

        WARNING: Will destroy the entire system. Should not be done until all managed contracts are destroyed.

        Params:
            fundReceiver (address) - The account that receives the funds.
    */
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