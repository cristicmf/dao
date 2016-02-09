/*
    File: Database.sol
    Author: Andreas Olofsson (androlo1980@gmail.com)
*/
import "./Doug.sol";

/*
    Contract: Database

    Interface for databases.
*/
contract Database is DougEnabled {

    /*
        Function: _checkCaller

        Method that implementations should use to check if an address is a valid caller.

        Returns:
            (bool) - True means the address was set successfully.
    */
    function _checkCaller() constant internal returns (bool);

}

/*
    Contract: DefaultDatabase

    Base contract for databases. Provides an internal method for checking if caller is an actions contract.

*/
contract DefaultDatabase is Database, DefaultDougEnabled {

    /*
        Function: _checkCaller

        Check if the caller is registered as an actions contract in doug.

        Returns:
            (bool) - True means the address was set successfully.
    */
    function _checkCaller() constant internal returns (bool) {
        return _DOUG.actionsContractId(msg.sender) != 0;
    }

}