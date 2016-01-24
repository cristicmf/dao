import "../../../dao-stl/src/errors/Errors.sol";
import "./Doug.sol";

/// @title Database
/// @author Andreas Olofsson (androlo1980@gmail.com)
/// @dev Base class for database contracts. Implements the 'DougEnabled' interface,
/// and provides an internal method for checking if caller is an actions contract.
contract Database is DefaultDougEnabled, Errors {

    // Check if the caller is an actions contract.
    function _checkCaller() constant internal returns (bool) {
        return _DOUG.actionsContractId(msg.sender) != 0;
    }
}