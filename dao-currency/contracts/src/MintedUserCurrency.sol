import "../../../dao-stl/src/errors/Errors.sol";
import "../../../dao-core/contracts/src/Doug.sol";
import "../../../dao-users/contracts/src/UserDatabase.sol";
import "./AbstractMintedCurrency.sol";
import "./CurrencyDatabase.sol";

/// @title MintedUserCurrency
/// @author Andreas Olofsson (androlo1980@gmail.com)
/// @dev Minted currency that can only be held by users. User checks are done using
/// a 'UserDatabase' contract.
contract MintedUserCurrency is AbstractMintedCurrency {

    UserDatabase _udb;

    function MintedUserCurrency(address currencyDatabase, address userDatabase, address minter
    ) AbstractMintedCurrency(currencyDatabase, minter) {
        _udb = UserDatabase(userDatabase);
    }

    /// @notice MintedUserCurrency.mint(receiver, amount) to mint new coins and add to an account.
    /// @dev Mint new coins and add to an account. Receiver must be registered in the provided 'UserDatabase'.
    /// @param receiver (address) the receiver account
    /// @param amount (uint) the amount
    /// @return error (uint16) error code
    function mint(address receiver, uint amount) returns (uint16 error) {
        if (receiver == 0 || amount == 0)
            return NULL_PARAM_NOT_ALLOWED;
        if (msg.sender != _minter)
            return ACCESS_DENIED;
        if (!_udb.hasUser(receiver))
            return RESOURCE_NOT_FOUND;
        return _cdb.add(receiver, int(amount));
    }

    /// @notice DefaultMintedCurrency.send(receiver, amount) to send coins from caller account to receiver.
    /// @dev Send coins from caller to receiver. Sender and receiver must be registered in the provided 'UserDatabase'.
    /// @param receiver (address) the receiver account
    /// @param amount (uint) the amount.
    /// @return error (uint16) error code
    function send(address receiver, uint amount) returns (uint16 error) {
        if (receiver == 0 || amount == 0)
            return NULL_PARAM_NOT_ALLOWED;
        var (u1, u2) = _udb.hasUsers(msg.sender, receiver);
        if (!(u1 && u2))
            return RESOURCE_NOT_FOUND;
        return _cdb.send(msg.sender, receiver, amount);
    }

}