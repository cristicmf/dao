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

    function registerUser(address addr, bytes32 nickname, bytes32 dataHash) returns (uint16 error) {
        if (msg.sender != _admin)
            return ACCESS_DENIED;
        if (addr == 0 || nickname == 0)
            return NULL_PARAM_NOT_ALLOWED;
        return _udb.registerUser(addr, nickname, block.timestamp, dataHash);
    }

    function removeUser(address addr) returns (uint16 error) {
        if (msg.sender != _admin && msg.sender != addr)
            return ACCESS_DENIED;
        if (addr == 0)
            return NULL_PARAM_NOT_ALLOWED;
        return _udb.removeUser(addr);
    }

    function removeSelf() returns (uint16 error) {
        return _udb.removeUser(msg.sender);
    }

    function updateDataHash(address addr, bytes32 dataHash) returns (uint16 error) {
        if (msg.sender != _admin)
            return ACCESS_DENIED;
        if (addr == 0)
            return NULL_PARAM_NOT_ALLOWED;
        return _udb.updateDataHash(addr, dataHash);
    }

    function updateMyDataHash(bytes32 dataHash) returns (uint16 error) {
        return _udb.updateDataHash(msg.sender, dataHash);
    }

}