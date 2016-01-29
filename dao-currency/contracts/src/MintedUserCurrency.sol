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

    UserDatabase _udb;

    /*
        Constructor: MintedUserCurrency

        Params:
            currencyDatabase (address) - The address to the currency database.
            userDatabase (address) - The address to the user database.
            minter (address) - The address of the minter.
    */
    function MintedUserCurrency(address currencyDatabase, address userDatabase, address minter
    ) AbstractMintedCurrency(currencyDatabase, minter) {
        _udb = UserDatabase(userDatabase);
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
        if (!_udb.hasUser(receiver))
            return RESOURCE_NOT_FOUND;
        return _cdb.add(receiver, int(amount));
    }

    /*
        Function: send

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
        var (u1, u2) = _udb.hasUsers(msg.sender, receiver);
        if (!(u1 && u2))
            return RESOURCE_NOT_FOUND;
        return _cdb.send(msg.sender, receiver, amount);
    }

}