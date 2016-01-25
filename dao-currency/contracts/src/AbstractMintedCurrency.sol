import "../../../dao-stl/src/errors/Errors.sol";
import "../../../dao-core/contracts/src/Doug.sol";
import "./MintedCurrency.sol";
import "./CurrencyDatabase.sol";

/// @title AbstractMintedCurrency
/// @author Andreas Olofsson (androlo1980@gmail.com)
/// @dev Implements 'setMinter', 'minter' and 'destroy' from 'MintedCurrency'.
contract AbstractMintedCurrency is MintedCurrency, DefaultDougEnabled, Errors {

    address _minter;
    CurrencyDatabase _cdb;

    function AbstractMintedCurrency(address currencyDatabase, address minter) {
        _cdb = CurrencyDatabase(currencyDatabase);
        _minter = minter;
    }

    /// @notice AbstractMintedCurrency.setMinter(minter) to set the minter address.
    /// @dev Set the minter address.
    /// @param minter (address) the minter
    /// @return error (uint16) error code
    function setMinter(address minter) returns (uint16 error) {
        // TODO null check.
        if (msg.sender != _minter)
            return ACCESS_DENIED;
        _minter = minter;
    }

    /// @notice AbstractMintedCurrency.minter() to get the minter account address.
    /// @dev Get minter account address.
    /// @return minter (address) the minter
    function minter() constant returns (address minter) {
        return _minter;
    }

    /// @notice AbstractMintedCurrency.setCurrencyDatabase(addr) to set the address of the currency database.
    /// @dev Set the address of the currency database. Can only be done by the minter.
    /// @param dbAddr (address) the database address.
    /// @return error (uint16) error code
    function setCurrencyDatabase(address dbAddr) returns (uint16 error) {
        if (msg.sender != _minter)
            return ACCESS_DENIED;
        _cdb = CurrencyDatabase(dbAddr);
    }

    /// @notice AbstractMintedCurrency.currencyDatabase() to get the address of the currency database.
    /// @dev Get the address of the currency database.
    /// @return dbAddr (address) the database address.
    function currencyDatabase() returns (address dbAddr) {
        return _cdb;
    }

}