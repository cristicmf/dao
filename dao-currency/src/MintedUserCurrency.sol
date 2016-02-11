/*
    File: MintedUserCurrency.sol

    Author: Andreas Olofsson (androlo1980@gmail.com)
*/
import "dao-stl/src/errors/Errors.sol";
import "dao-core/src/Doug.sol";
import "dao-users/src/UserDatabase.sol";
import "./AbstractMintedCurrency.sol";
import "./CurrencyDatabase.sol";

/*
    Contract: MintedUserCurrency

    Minted currency that can only be held by users. User checks are done using a 'UserDatabase' contract.
*/
contract MintedUserCurrency is AbstractMintedCurrency {

    /*
        Event: SetUserDatabase

        Params:
            dbAddr (address) - The address.
            error (uint16) - An error code.
    */
    event SetUserDatabase(address indexed dbAddr, uint16 indexed error);

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
            error = NULL_PARAM_NOT_ALLOWED;
        else if (msg.sender != _minter)
            error = ACCESS_DENIED;
        else if (!_userDatabase.hasUser(receiver))
            error = RESOURCE_NOT_FOUND;
        else
            error = _currencyDatabase.add(receiver, int(amount));

        Mint(receiver, amount, error);
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
            error =  NULL_PARAM_NOT_ALLOWED;
        else {
            var (u1, u2) = _userDatabase.hasUsers(msg.sender, receiver);
            if (!(u1 && u2))
                error = RESOURCE_NOT_FOUND;
            else
                error = _currencyDatabase.send(msg.sender, receiver, amount);
        }

        Send(msg.sender, receiver, amount, error);
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
            error = NULL_PARAM_NOT_ALLOWED;
        else if (msg.sender != _minter)
            error = ACCESS_DENIED;
        else {
            var (u1, u2) = _userDatabase.hasUsers(msg.sender, receiver);
            if (!(u1 && u2))
                error = RESOURCE_NOT_FOUND;
            else
                error = _currencyDatabase.send(msg.sender, receiver, amount);
        }

        Send(sender, receiver, amount, error);
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