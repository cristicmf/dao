import "./Asserter.sol";
import "../errors/Errors.sol";

/*
    Contract: DaoAsserter

    Contract that extends <Asserter> and adds assertions for DAO framework error codes.

    Author: Andreas Olofsson (androlo1980@gmail.com)
*/
contract DaoAsserter is Asserter, Errors {

    /*
        Function: assertErrorsEqual

        Assert that two error codes (uint16) are equal.

        : errorCode1 == errorCode2

        Params:
            errorCode1 (uint16) - the first error code.
            errorCode2 (uint16) - the second error code.
            message (string) - A message to display if the assertion does not hold.

        Returns:
            result (bool) - The result.
    */
    function assertErrorsEqual(uint16 errorCode1, uint16 errorCode2, string message) internal constant returns (bool result) {
        result = (errorCode1 == errorCode2);
        _report(result, message);
    }

    /*
        Function: assertErrorsNotEqual

        Assert that two error codes (uint16) are not equal.

        : errorCode1 != errorCode2

        Params:
            errorCode1 (uint16) - the first error code.
            errorCode2 (uint16) - the second error code.
            message (string) - A message to display if the assertion does not hold.

        Returns:
            result (bool) - The result.
    */
    function assertErrorsNotEqual(uint16 errorCode1, uint16 errorCode2, string message) internal constant returns (bool result) {
        result = (errorCode1 != errorCode2);
        _report(result, message);
    }

    /*
        Function: assertError

        Assert that the code (uint16) is not the null error.

        : errorCode != Errors.NO_ERROR

        Params:
            errorCode (uint16) - the error code.
            message (string) - A message to display if the assertion does not hold.

        Returns:
            result (bool) - The result.
    */
    function assertError(uint16 errorCode, string message) internal constant returns (bool result) {
        result = (errorCode != NO_ERROR);
        _report(result, message);
    }

    /*
        Function: assertError

        Assert that the code (uint16) is the null error.

        : errorCode == Errors.NO_ERROR

        Params:
            errorCode (uint16) - the error code.
            message (string) - A message to display if the assertion does not hold.

        Returns:
            result (bool) - The result.
    */
    function assertNoError(uint16 errorCode, string message) internal constant returns (bool result) {
        result = (errorCode == NO_ERROR);
        _report(result, message);
    }

}