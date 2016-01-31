import "./Asserter.sol";
import "../errors/Errors.sol";

/*
    Contract: DaoAsserter

    Contract that extends <Asserter> and extends Error. Convenience contract.

    Author: Andreas Olofsson (androlo1980@gmail.com)
*/
contract DaoAsserter is Asserter, Errors {}