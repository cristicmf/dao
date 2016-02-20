/*
    File: DefaultCurrencyDatabase.sol

    Author: Andreas Olofsson (androlo1980@gmail.com)
*/
import "./CurrencyDatabase.sol";
import "dao-core/src/Database.sol";

/*
    Contract: DefaultCurrencyDatabase

    Default implementation of CurrencyDatabase. To save sapce, the balance mapping is not iterable.
    Applications are expected to already have an iterable collection of users (such as 'DefaultUserDatabase') which can be used instead.
*/
contract DefaultCurrencyDatabase is CurrencyDatabase, DefaultDatabase {

    mapping (address => uint) _balances;

    /*
        Constructor: DefaultCurrencyDatabase

        Params:
            actionsName (bytes32) - The name of the actions contract with write privileges..
    */
    function DefaultCurrencyDatabase(bytes32 actionsName) DefaultDatabase(actionsName) {}


    /*
        Function: add

        Add currency to an account.

        Params:
            receiver (address) - The receiver account.
            amount (int) - The amount. Use a negative value to subtract.

        Returns:
            error (uint16) - An error code.
    */
    function add(address receiver, int amount) returns (uint16 error) {
        if (!_checkCaller()) {
            return ACCESS_DENIED;
        }
        if (amount < 0) {
            if (_balances[receiver] < uint(-amount))
                return TRANSFER_FAILED;
            else
                _balances[receiver] -= uint(-amount);
        }
        else
            _balances[receiver] += uint(amount);
    }

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
    function send(address sender, address receiver, uint amount) returns (uint16 error) {
        if (!_checkCaller())
            return ACCESS_DENIED;
        if (_balances[sender] < amount)
            return INSUFFICIENT_SENDER_BALANCE;
        _balances[sender] -= amount;
        _balances[receiver] += amount;
    }

    /*
        Function: accountBalance

        Get the current balance of an account.

        Params:
            addr (address) - The account address.

        Returns:
            balance (uint) - The balance.
    */
    function accountBalance(address addr) constant returns (uint balance) {
        return _balances[addr];
    }

}