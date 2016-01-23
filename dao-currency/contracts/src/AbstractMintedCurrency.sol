import "../../../dao-stl/src/errors/Errors.sol";
import "../../../dao-core/contracts/src/Doug.sol";
import "./MintedCurrency.sol";

/// @title AbstractMintedCurrency
/// @author Andreas Olofsson (androlo1980@gmail.com)
/// @dev Default implementation of a minted currency.
contract AbstractMintedCurrency is MintedCurrency, DefaultDougEnabled, Errors {

    address _minter;

    function AbstractMintedCurrency(address minter) {
        _minter = minter;
    }

    function setMinter(address minter) returns (uint16 error) {
        if (msg.sender != _minter)
            return ACCESS_DENIED;
        _minter = minter;
    }

    function minter() constant returns (address minter) {
        return _minter;
    }

    function destroy(address fundReceiver) {
        if (msg.sender == address(_DOUG))
            selfdestruct(fundReceiver);
    }

}