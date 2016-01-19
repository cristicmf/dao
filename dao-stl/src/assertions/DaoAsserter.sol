import "./Asserter.sol";
import "../errors/Errors.sol";

contract DaoAsserter is Asserter, Errors {

    /// @dev Assert that the two error codes (uint16) are equal.
    /// @param errorCode The first error code.
    /// @param errorCode2 The second error code.
    /// @param message The message to display if the assertion fails.
    function assertErrorsEqual(uint16 errorCode, uint16 errorCode2, string message) internal constant returns (bool result) {
        result = (errorCode == errorCode2);
        report(result, message);
    }

    /// @dev Assert that the two error codes (uint16) are not equal.
    /// @param errorCode The first error code.
    /// @param errorCode2 The second error code.
    /// @param message The message to display if the assertion fails.
    function assertErrorsNotEqual(uint16 errorCode, uint16 errorCode2, string message) internal constant returns (bool result) {
        result = (errorCode != errorCode2);
        report(result, message);
    }

    /// @dev Assert that there is an error (errorCode != NO_ERROR)
    /// @param errorCode The error code.
    /// @param message The message to display if the assertion fails.
    function assertError(uint16 errorCode, string message) internal constant returns (bool result) {
        result = (errorCode != NO_ERROR);
        report(result, message);
    }

    /// @dev Assert that there is no error (errorCode == NO_ERROR)
    /// @param errorCode The error code.
    /// @param message The message to display if the assertion fails.
    function assertNoError(uint16 errorCode, string message) internal constant returns (bool result) {
        result = (errorCode == NO_ERROR);
        report(result, message);
    }

}