/*
    File: CurrencyDatabase.sol
    Author: Andreas Olofsson (androlo1980@gmail.com)
*/
import "dao-core/src/Database.sol";

/*
    Contract: CurrencyDatabase

    CurrencyDatabase is an interface for contracts that keeps track of currency balance.
*/
contract CurrencyDatabase is Database {

    /*
        Function: add

        Add currency to an account.

        Params:
            receiver (address) - The receiver account.
            amount (int) - The amount. Use a negative value to subtract.

        Returns:
            error (uint16) - An error code.
    */
    function add(address receiver, int amount) returns (uint16 error);

    /*
        Function: send

        Send currency between accounts.

        Params:
            sender (address) - The sender account.
            receiver (address) - The receiver account.
            amount (int) - The amount. Use a negative value to subtract.

        Returns:
            error (uint16) - An error code.
    */
    function send(address sender, address receiver, uint amount) returns (uint16 error);

    /*
        Function: accountBalance

        Get the current balance of an account.

        Params:
            addr (address) - The account address.

        Returns:
            balance (uint) - The balance.
    */
    function accountBalance(address addr) constant returns (uint balance);

}