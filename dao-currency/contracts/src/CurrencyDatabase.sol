import "../../../dao-core/contracts/src/Database.sol";

/// @title CurrencyDatabase
/// @author Andreas Olofsson (androlo1980@gmail.com)
/// @dev CurrencyDatabase keeps track of users currency balance.
contract CurrencyDatabase is Database {

    /// @notice CurrencyDatabase.add(receiver, amount) to add currency to an account.
    /// @dev Add currency to an account.
    /// @param receiver (address) the receiver account
    /// @param amount (int) the amount. Use a negative value to subtract.
    /// @return error (uint16) error code.
    function add(address receiver, int amount) returns (uint16 error);

    /// @notice CurrencyDatabase.send(sender, receiver, amount) to send currency from one account to another.
    /// @dev Send currency between accounts.
    /// @param sender (address) the sender account
    /// @param receiver (address) the receiver account
    /// @param amount (uint) the amount.
    /// @return error (uint16) error code.
    function send(address sender, address receiver, uint amount) returns (uint16 error);

    /// @notice CurrencyDatabase.accountBalance(addr) get the balance of an account.
    /// @dev Get the balance of an account.
    /// @param addr (address) the account address
    /// @return balance (uint) the balance
    function accountBalance(address addr) constant returns (uint balance);

}