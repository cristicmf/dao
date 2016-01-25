import "./AbstractMintedCurrency.sol";
import "./CurrencyDatabase.sol";

/// @title DefaultMintedCurrency
/// @author Andreas Olofsson (androlo1980@gmail.com)
/// @dev Default implementation of a minted currency.
contract DefaultMintedCurrency is AbstractMintedCurrency {

    function DefaultMintedCurrency(address currencyDatabase, address minter) AbstractMintedCurrency(currencyDatabase, minter) {}

    /// @notice DefaultMintedCurrency.mint(receiver, amount) to mint new coins and add to an account.
    /// @dev Mint new coins and add to an account.
    /// @param receiver (address) the receiver account
    /// @param amount (uint) the amount
    /// @return error (uint16) error code
    function mint(address receiver, uint amount) returns (uint16 error) {
        if (receiver == 0 || amount == 0)
            return NULL_PARAM_NOT_ALLOWED;
        if (msg.sender != _minter)
            return ACCESS_DENIED;
        return _cdb.add(receiver, int(amount));
    }

    /// @notice DefaultMintedCurrency.send(receiver, amount) to send coins from caller account to receiver.
    /// @dev Send coins from caller to receiver.
    /// @param receiver (address) the receiver account
    /// @param amount (uint) the amount.
    /// @return error (uint16) error code
    function send(address receiver, uint amount) returns (uint16 error) {
        if (receiver == 0 || amount == 0)
            return NULL_PARAM_NOT_ALLOWED;
        return _cdb.send(msg.sender, receiver, amount);
    }

}