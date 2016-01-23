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

    CurrencyDatabase _cdb;
    UserDatabase _udb;

    function MintedUserCurrency(address currencyDatabase, address userDatabase, address minter
    ) AbstractMintedCurrency(minter) {
        _cdb = CurrencyDatabase(currencyDatabase);
        _udb = UserDatabase(userDatabase);
    }

    function mint(address receiver, uint amount) returns (uint16 error) {
        if (msg.sender != _minter)
            return ACCESS_DENIED;
        if (!_udb.hasUser(receiver))
            return RESOURCE_NOT_FOUND;
        return _cdb.add(receiver, int(amount));
    }

    function send(address receiver, uint amount) returns (uint16 error) {
        var (u1, u2) = _udb.hasUsers(msg.sender, receiver);
        if (!(u1 && u2))
            return RESOURCE_NOT_FOUND;
        return _cdb.send(msg.sender, receiver, amount);
    }

}