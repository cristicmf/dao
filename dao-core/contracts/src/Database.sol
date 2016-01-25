import "../../../dao-stl/src/errors/Errors.sol";
import "./Doug.sol";

/// @title Database
/// @author Andreas Olofsson (androlo1980@gmail.com)
/// @dev Interface for databases. Implements the 'DougEnabled' interface.
contract Database is DougEnabled {

    // Check if the caller is an actions contract.
    function _checkCaller() constant internal returns (bool);

}

/// @title DefaultDatabase
/// @author Andreas Olofsson (androlo1980@gmail.com)
/// @dev Base contract for databases. Implements the 'DougEnabled' interface,
/// and provides an internal method for checking if caller is an actions contract.
contract DefaultDatabase is Database, DefaultDougEnabled, Errors {

    // Check if the caller is an actions contract.
    function _checkCaller() constant internal returns (bool) {
        return _DOUG.actionsContractId(msg.sender) != 0;
    }

}