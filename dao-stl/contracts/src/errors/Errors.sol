/// @title Errors
/// @author Andreas Olofsson (andolo1980@gmail.com)
/// CONTRACT:
/// Errors. Categories offset by 1000; each with a generic message at the start. Sub-categories offset by 100.
contract Errors {

    // ********************** Normal execution **********************

    uint16 constant NO_ERROR = 0;
    uint16 constant ERROR = 1;

    // ********************** Resources **********************

    uint16 constant RESOURCE_ERROR = 1000;
    uint16 constant RESOURCE_NOT_FOUND = 1001;
    uint16 constant RESOURCE_ALREADY_EXISTS = 1002;

    // ********************** Access **********************

    uint16 constant ACCESS_DENIED = 2000;

    // ********************** Input **********************

    uint16 constant PARAMETER_ERROR = 3000;
    uint16 constant INVALID_PARAM_VALUE = 3001;
    uint16 constant NULL_PARAM_NOT_ALLOWED = 3002;
    uint16 constant INTEGER_OUT_OF_BOUNDS = 3003;
    // Arrays
    uint16 constant ARRAY_INDEX_OUT_OF_BOUNDS = 3100;

    // ********************** Contract states *******************

    // Catch all for when the state of the contract does not allow the operation.
    uint16 constant INVALID_STATE = 4000;

    // ********************** Transfers *******************
    // Transferring some form of value from one account to another is very common,
    // so it should have default error codes.

    uint16 constant TRANSFER_FAILED = 8000;
    uint16 constant NO_SENDER_ACCOUNT = 8001;
    uint16 constant NO_TARGET_ACCOUNT = 8002;
    uint16 constant TARGET_IS_SENDER = 8003;
    uint16 constant TRANSFER_NOT_ALLOWED = 8004;

    // Balance-related.
    uint16 constant INSUFFICIENT_SENDER_BALANCE = 8100;
    uint16 constant TRANSFERRED_AMOUNT_TOO_HIGH = 8101;

}