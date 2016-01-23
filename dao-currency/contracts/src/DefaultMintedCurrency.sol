import "./AbstractMintedCurrency.sol";
import "./CurrencyDatabase.sol";

/// @title DefaultMintedCurrency
/// @author Andreas Olofsson (androlo1980@gmail.com)
/// @dev Default implementation of a minted currency.
contract DefaultMintedCurrency is AbstractMintedCurrency {

    CurrencyDatabase _cdb;

    function DefaultMintedCurrency(address coinDb, address minter) AbstractMintedCurrency(minter) {
        _cdb = CurrencyDatabase(coinDb);
    }

    function mint(address receiver, uint amount) returns (uint16 error) {
        if (msg.sender != _minter)
            return ACCESS_DENIED;
        return _cdb.add(receiver, int(amount));
    }

    function send(address receiver, uint amount) returns (uint16 error) {
        return _cdb.send(msg.sender, receiver, amount);
    }

}