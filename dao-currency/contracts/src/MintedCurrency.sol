import "../../../dao-core/contracts/src/Doug.sol";

/// @title MintedCurrency
/// @author Andreas Olofsson (androlo1980@gmail.com)
/// @dev Interface for currency actions contracts that has a minter.
contract MintedCurrency is DougEnabled {

    /// @notice MintedCurrency.mint(receiver, amount) to mint new coins and add to an account.
    /// @dev Mint new coins and add to an account.
    /// @param receiver (address) the receiver account
    /// @param amount (uint) the amount
    /// @return error (uint16) error code
    function mint(address receiver, uint amount) returns (uint16 error);

    /// @notice MintedCurrency.send(receiver, amount) to send coins from caller account to receiver.
    /// @dev Send coins from caller to receiver.
    /// @param receiver (address) the receiver account
    /// @param amount (uint) the amount.
    /// @return error (uint16) error code
    function send(address receiver, uint amount) returns (uint16 error);

    /// @notice MintedCurrency.setMinter(minter) to set the minter address.
    /// @dev Set the minter address.
    /// @param minter (address) the minter
    /// @return error (uint16) error code
    function setMinter(address minter) returns (uint16 error);

    /// @notice MintedCurrency.minter() to get the minter account address.
    /// @dev Get minter account address.
    /// @return minter (address) the minter
    function minter() constant returns (address minter);

    /// @notice MintedCurrency.setCurrencyDatabase(addr) to set the address of the currency database.
    /// @dev Set the address of the currency database.
    /// @param dbAddr (address) the database address.
    /// @return error (uint16) error code
    function setCurrencyDatabase(address dbAddr) returns (uint16 error);

}