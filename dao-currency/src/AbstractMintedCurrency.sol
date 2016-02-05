import "dao-core/src/Doug.sol";
import "./MintedCurrency.sol";
import "./CurrencyDatabase.sol";

/*
    Contract: AbstractMintedCurrency

    Implements 'setMinter', 'minter' and 'destroy' from <MintedCurrency>.

    Author: Andreas Olofsson (androlo1980@gmail.com)
*/
contract AbstractMintedCurrency is MintedCurrency, DefaultDougEnabled {

    address _minter;
    CurrencyDatabase _currencyDatabase;

    /*
        Constructor: AbstractMintedCurrency

        Params:
            currencyDatabase (address) - The address to the currency database.
    */
    function AbstractMintedCurrency(address currencyDatabase, address minter) {
        _currencyDatabase = CurrencyDatabase(currencyDatabase);
        _minter = minter;
    }

    /*
        Function: setMinter

        Set the minter address. Can only be done by the minter.

        Params:
            minter (address) - The address of the new minter.

        Returns:
            error (uint16) - An error code.
    */
    function setMinter(address minter) returns (uint16 error) {
        if (minter == 0)
            error = NULL_PARAM_NOT_ALLOWED;
        else if (msg.sender != _minter)
            error = ACCESS_DENIED;
        else
            _minter = minter;

        SetMinter(minter, error);
    }

    /*
        Function: minter

        Get the minter address.

        Returns:
            minter (address) - The address.
    */
    function minter() constant returns (address minter) {
        return _minter;
    }

    /*
        Function: setCurrencyDatabase

        Set the address of the currency database. Can only be done by the minter.

        Params:
            dbAddr (address) - The new currency database address.

        Returns:
            error (uint16) - An error code.
    */
    function setCurrencyDatabase(address dbAddr) returns (uint16 error) {
        if (msg.sender != _minter)
            error = ACCESS_DENIED;
        else
            _currencyDatabase = CurrencyDatabase(dbAddr);

        SetCurrencyDatabase(dbAddr, error);
    }

    /*
        Function: currencyDatabase

        Get the address of the currency database.

        Returns:
            dbAddr (address) - The address.
    */
    function currencyDatabase() returns (address dbAddr) {
        return _currencyDatabase;
    }

}