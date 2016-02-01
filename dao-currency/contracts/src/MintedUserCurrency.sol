import "../../../dao-stl/contracts/src/errors/Errors.sol";
import "../../../dao-core/contracts/src/Doug.sol";
import "../../../dao-users/contracts/src/UserDatabase.sol";
import "./AbstractMintedCurrency.sol";
import "./CurrencyDatabase.sol";

/*
    Contract: DefaultMintedCurrency

    Minted currency that can only be held by users. User checks are done using a 'UserDatabase' contract.

    Author: Andreas Olofsson (androlo1980@gmail.com)
*/
contract MintedUserCurrency is AbstractMintedCurrency {

    UserDatabase _userDatabase;

    /*
        Constructor: MintedUserCurrency

        Params:
            currencyDatabase (address) - The address to the currency database.
            userDatabase (address) - The address to the user database.
            minter (address) - The address of the minter.
    */
    function MintedUserCurrency(address currencyDatabase, address userDatabase, address minter
    ) AbstractMintedCurrency(currencyDatabase, minter) {
        _userDatabase = UserDatabase(userDatabase);
    }

    /*
        Function: mint

        Mint new coins and add to an account. Minter is automatically set to 'msg.sender'.

        Receiver must be registered in the provided 'UserDatabase'.

        Params:
            receiver (address) - The receiver account.
            amount (int) - The amount. Use a negative value to subtract.

        Returns:
            error (uint16) - An error code.
    */
    function mint(address receiver, uint amount) returns (uint16 error) {
        if (receiver == 0 || amount == 0)
            return NULL_PARAM_NOT_ALLOWED;
        if (msg.sender != _minter)
            return ACCESS_DENIED;
        if (!_userDatabase.hasUser(receiver))
            return RESOURCE_NOT_FOUND;
        error = _currencyDatabase.add(receiver, int(amount));
        if (error == NO_ERROR)
            CoinsMinted(receiver, amount);
    }

    /*
        Function: send(address, uint)

        Send currency between accounts. Sender is automatically set to 'msg.sender'.

        Sender and receiver must both be registered in the provided 'UserDatabase'.

        Params:
            receiver (address) - The receiver account.
            amount (int) - The amount. Use a negative value to subtract.

        Returns:
            error (uint16) - An error code.
    */
    function send(address receiver, uint amount) returns (uint16 error) {
        if (receiver == 0 || amount == 0)
            return NULL_PARAM_NOT_ALLOWED;
        var (u1, u2) = _userDatabase.hasUsers(msg.sender, receiver);
        if (!(u1 && u2))
            return RESOURCE_NOT_FOUND;
        error = _currencyDatabase.send(msg.sender, receiver, amount);
        if (error == NO_ERROR)
            CoinsTransferred(msg.sender, receiver, amount);
    }

    /*
        Function: send(address, address, amount)

        Send currency between accounts. Can only be used by the administrator (minter).

        Params:
            sender (address) - The sender account.
            receiver (address) - The receiver account.
            amount (int) - The amount. Use a negative value to subtract.

        Returns:
            error (uint16) - An error code.
    */
    function send(address sender, address receiver, uint amount) returns (uint16 error) {
        if (sender == 0 || receiver == 0 || amount == 0)
            return NULL_PARAM_NOT_ALLOWED;
        if (msg.sender != _minter)
            return ACCESS_DENIED;
        var (u1, u2) = _userDatabase.hasUsers(msg.sender, receiver);
        if (!(u1 && u2))
            return RESOURCE_NOT_FOUND;
        error = _currencyDatabase.send(msg.sender, receiver, amount);
        if (error == NO_ERROR)
            CoinsTransferred(sender, receiver, amount);
    }
    
    /*
        Function: userDatabase

        Get the address of the user database.

        Returns:
            dbAddr (address) - The database address.
    */
    function userDatabase() returns (address dbAddr) {
        return _userDatabase;
    }

}