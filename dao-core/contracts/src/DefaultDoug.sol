import "../../../dao-stl/src/errors/Errors.sol";
import {Doug, DougEnabled, Destructible} from "./Doug.sol";
import "./Permission.sol";

/// @title DefaultDoug
/// @author Andreas Olofsson (androlo1980@gmail.com)
/// @dev Default implementation of the 'Doug' interface-contract.
/// Most collections work is done internally, rather then through a library.
contract DefaultDoug is Doug, Errors {

    address constant ADDRESS_NULL = 0;
    bytes32 constant BYTES32_NULL = 0;

    bool _destroyRemovedActions;
    bool _destroyRemovedDatabases;

    Permission _permission;

    // Element used in NAMap.
    struct NAElement {
        uint _keyIndex;
        address _value;
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

    function DefaultDoug(address permissionAddress, bool destroyActions, bool destroyDatabases) {
        _permission = Permission(permissionAddress);
        _destroyRemovedActions = destroyActions;
        _destroyRemovedDatabases = destroyDatabases;
    }

    // *********************************** Actions contracts ************************************

    function addActionsContract(bytes32 identifier, address contractAddress) external returns (uint16 error) {
        error = _addContract(_aMap, identifier, contractAddress);
        if (error == NO_ERROR)
            ActionsContractAdded(identifier, contractAddress);
    }

    function removeActionsContract(bytes32 identifier) external returns (uint16 error){
        var (addr, err) = _removeContract(_aMap, identifier);
        if (err == NO_ERROR) {
            ActionsContractRemoved(identifier, addr);
            if (_destroyRemovedActions)
                Destructible(addr).destroy(_permission.root());
        }
        return err;
    }

    function actionsContractAddress(bytes32 identifier) constant returns (address contractAddress) {
         return _aMap._data[identifier]._value;
    }

    function actionsContractId(address contractAddress) constant returns (bytes32 identifier) {
         return _aMap._aToN[contractAddress];
    }

    function actionsContractFromIndex(uint index) constant returns (bytes32 identifier, address contractAddress, uint16 error) {
        return _contractFromIndex(_aMap, index);
    }

    function numActionsContracts() constant returns (uint numContracts) {
        return _aMap._keys.length;
    }

    function setDestroyRemovedActions(bool destroyRemovedActions) returns (uint16 error) {
        if (!_hasDougPermission())
            return ACCESS_DENIED;
        _destroyRemovedActions = destroyRemovedActions;
    }

    function destroyRemovedActions() constant returns (bool destroyRemovedActions) {
        return _destroyRemovedActions;
    }

    // *********************************** Database contracts ************************************

    function addDatabaseContract(bytes32 identifier, address contractAddress) external returns (uint16 error) {
        error = _addContract(_dMap, identifier, contractAddress);
        if (error == NO_ERROR)
            DatabaseContractAdded(identifier, contractAddress);
    }

    function removeDatabaseContract(bytes32 identifier) external returns (uint16 error) {
        var (addr, err) = _removeContract(_dMap, identifier);
        if (err == NO_ERROR) {
            DatabaseContractRemoved(identifier, addr);
            if (_destroyRemovedDatabases)
                Destructible(addr).destroy(_permission.root());
        }
        return err;
    }

    function databaseContractAddress(bytes32 identifier) constant returns (address contractAddress) {
         return _dMap._data[identifier]._value;
    }

    function databaseContractId(address contractAddress) constant returns (bytes32 identifier) {
         return _dMap._aToN[contractAddress];
    }

    function databaseContractFromIndex(uint index) constant returns (bytes32 identifier, address contractAddress, uint16 error) {
        return _contractFromIndex(_dMap, index);
    }

    function numDatabaseContracts() constant returns (uint numContracts) {
        return _dMap._keys.length;
    }

    function setDestroyRemovedDatabases(bool destroyRemovedDatabases) returns (uint16 error) {
        if (!_hasDougPermission())
            return ACCESS_DENIED;
        _destroyRemovedDatabases = destroyRemovedDatabases;
    }

    function destroyRemovedDatabases() constant returns (bool destroyRemovedDatabases) {
        return _destroyRemovedDatabases;
    }

    // *********************************** Doug specific ************************************

    function setPermission(address permissionAddress) returns (uint16 error) {
        // Only allow
        if (address(_permission) != ADDRESS_NULL && msg.sender != _permission.root())
            return ACCESS_DENIED;
        _permission = Permission(permissionAddress);
    }

    function permissionAddress() constant returns (address pmAddress) {
        return _permission;
    }

    function destroy(address fundReceiver) {
        if (msg.sender == _permission.root()) {
            selfdestruct(fundReceiver);
        }
    }

    // *********************************** Internal ************************************

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

        var oldAddress = map._data[identifier]._value;
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
            map._data[identifier]._value = contractAddress;
        // Register ID under the given address.
        map._aToN[contractAddress] = identifier;
    }

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
        addr = elem._value;
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

    function _contractFromIndex(NAMap storage map, uint index) internal constant returns (bytes32 identifier, address contractAddress, uint16 error) {
        if (index >= map._keys.length) {
            error = ARRAY_INDEX_OUT_OF_BOUNDS;
            return;
        }
        identifier = map._keys[index];
        contractAddress = map._data[identifier]._value;
    }

    function _hasDougPermission() constant internal returns (bool isRoot) {
        return address(_permission) != 0 && _permission.hasPermission(msg.sender);
    }

}