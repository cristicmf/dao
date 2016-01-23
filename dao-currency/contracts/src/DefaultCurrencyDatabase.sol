import "./CurrencyDatabase.sol";

/// @title DefaultCurrencyDatabase
/// @author Andreas Olofsson (androlo1980@gmail.com)
/// @dev Default implementation of CurrencyDatabase.
contract DefaultCurrencyDatabase is CurrencyDatabase {

    // No iterable mapping here. Iterate over users instead.
    mapping (address => uint) _balances;

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

    function send(address sender, address receiver, uint amount) returns (uint16 error) {
        if (!_checkCaller())
            return ACCESS_DENIED;
        if (_balances[sender] < amount)
            return INSUFFICIENT_SENDER_BALANCE;
        _balances[sender] -= amount;
        _balances[receiver] += amount;
    }

    function accountBalance(address addr) constant returns (uint balance) {
        return _balances[addr];
    }

    function destroy(address fundReceiver) {
        if (msg.sender == address(_DOUG))
            selfdestruct(fundReceiver);
    }

}