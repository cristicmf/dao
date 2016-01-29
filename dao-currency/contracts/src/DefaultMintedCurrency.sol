import "./AbstractMintedCurrency.sol";
import "./CurrencyDatabase.sol";

/*
    Contract: DefaultMintedCurrency

    Default implementation of 'MintedCurrency'.

    Author: Andreas Olofsson (androlo1980@gmail.com)
*/
contract DefaultMintedCurrency is AbstractMintedCurrency {

    /*
        Constructor: DefaultMintedCurrency

        Params:
            currencyDatabase (address) - The address to the currency database.
            minter (address) - The address of the minter.
    */
    function DefaultMintedCurrency(address currencyDatabase, address minter) AbstractMintedCurrency(currencyDatabase, minter) {}

    /*
        Function: mint

        Mint new coins and add to an account. Minter is automatically set to 'msg.sender'.

        Params:
            receiver (address) - The receiver account.
            amount (int) - The amount. Use a negative value to subtract.

        Returns:
            error (uint16) - An error code.
    */
    function mint(address receiver, uint amount) returns (uint16 error) {
        if (receiver == 0 || amount == 0)
            return NULL_PARAM_NOT_ALLOWED;
        if (msg.sender != _minter)
            return ACCESS_DENIED;
        return _cdb.add(receiver, int(amount));
    }

    /*
        Function: send

        Send currency between accounts. Sender is automatically set to 'msg.sender'.

        Params:
            receiver (address) - The receiver account.
            amount (int) - The amount. Use a negative value to subtract.

        Returns:
            error (uint16) - An error code.
    */
    function send(address receiver, uint amount) returns (uint16 error) {
        if (receiver == 0 || amount == 0)
            return NULL_PARAM_NOT_ALLOWED;
        return _cdb.send(msg.sender, receiver, amount);
    }

}