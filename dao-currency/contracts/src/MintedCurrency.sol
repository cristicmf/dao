import "../../../dao-core/contracts/src/Doug.sol";

/*
    Interface: MintedCurrency

    Interface for currency actions contracts that has a minter.

    Author: Andreas Olofsson (androlo1980@gmail.com)
*/
contract MintedCurrency is DougEnabled {

    /*
        Function: mint

        Mint new coins and add to an account. Minter is automatically set to 'msg.sender'.

        Params:
            receiver (address) - The receiver account.
            amount (int) - The amount. Use a negative value to subtract.

        Returns:
            error (uint16) - An error code.
    */
    function mint(address receiver, uint amount) returns (uint16 error);

    /*
        Function: send

        Send currency between accounts. Sender is automatically set to 'msg.sender'.

        Params:
            receiver (address) - The receiver account.
            amount (int) - The amount. Use a negative value to subtract.

        Returns:
            error (uint16) - An error code.
    */
    function send(address receiver, uint amount) returns (uint16 error);

    /*
        Function: setMinter

        Set the minter address.

        Params:
            minter (address) - The address of the new minter.

        Returns:
            error (uint16) - An error code.
    */
    function setMinter(address minter) returns (uint16 error);

    /*
        Function: minter

        Get the minter address.

        Returns:
            minter (address) - The address.
    */
    function minter() constant returns (address minter);

    /*
        Function: setCurrencyDatabase

        Set the address of the currency database.

        Params:
            dbAddr (address) - The new currency database address.

        Returns:
            error (uint16) - An error code.
    */
    function setCurrencyDatabase(address dbAddr) returns (uint16 error);

    /*
        Function: currencyDatabase

        Get the address of the currency database.

        Returns:
            dbAddr (address) - The address.
    */
    function currencyDatabase() returns (address dbAddr);

}