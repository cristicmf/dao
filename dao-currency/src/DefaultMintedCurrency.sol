/*
    File: DefaultMintedCurrency.sol
    Author: Andreas Olofsson (androlo1980@gmail.com)
*/
import "./AbstractMintedCurrency.sol";
import "./CurrencyDatabase.sol";

/*
    Contract: DefaultMintedCurrency

    Default implementation of 'MintedCurrency'.
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
            error = NULL_PARAM_NOT_ALLOWED;
        else if (msg.sender != _minter)
            error = ACCESS_DENIED;
        else
            error = _currencyDatabase.add(receiver, int(amount));

        Mint(receiver, amount, error);
    }

    /*
        Function: send(address, uint)

        Send currency between accounts. Sender is automatically set to 'msg.sender'.

        Params:
            receiver (address) - The receiver account.
            amount (int) - The amount. Use a negative value to subtract.

        Returns:
            error (uint16) - An error code.
    */
    function send(address receiver, uint amount) returns (uint16 error) {
        if (receiver == 0 || amount == 0)
            error = NULL_PARAM_NOT_ALLOWED;
        else
            error = _currencyDatabase.send(msg.sender, receiver, amount);

        Send(msg.sender, receiver, amount, error);
    }

    /*
        Function: send(address, address, amount)

        Send currency between accounts. Can only be used by the administrator (minter).

        Params:
            sender (address) - The sender account.
            receiver (address) - The receiver account.
            amount (int) - The amount. Use a negative value to subtract.

        Returns:
            error (uint16) - An error code.
    */
    function send(address sender, address receiver, uint amount) returns (uint16 error) {
        if (sender == 0 || receiver == 0 || amount == 0)
            error = NULL_PARAM_NOT_ALLOWED;
        else if (msg.sender != _minter)
            error = ACCESS_DENIED;
        else
            error = _currencyDatabase.send(msg.sender, receiver, amount);

        Send(sender, receiver, amount, error);
    }

}