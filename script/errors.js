/**
 * @file errors.js
 * @fileOverview Javascript for interpreting error codes. These are the codes used in the Errors.sol contract.
 * @author Andreas Olofsson (androlo1980@gmail.com)
 * @module errors
 */
'use strict';

var errors = {};

errors[0] = "NO_ERROR";
errors[1] = "ERROR";

// ********************** Resources **********************
errors[1000] = "RESOURCE_ERROR";
errors[1001] = "RESOURCE_NOT_FOUND";
errors[1002] = "RESOURCE_ALREADY_EXISTS";

// ********************** Access **********************
errors[2000] = "ACCESS_DENIED";

// ********************** Input **********************
errors[3000] = "PARAMETER_ERROR";
errors[3001] = "INVALID_PARAM_VALUE";
errors[3002] = "NULL_PARAM_NOT_ALLOWED";
errors[3003] = "INTEGER_OUT_OF_BOUNDS";
errors[3100] = "ARRAY_INDEX_OUT_OF_BOUNDS";

// ********************** Contract states *******************
errors[4000] = "INVALID_STATE";

// ********************** Transfers *******************
errors[8000] = "TRANSFER_FAILED";
errors[8001] = "NO_SENDER_ACCOUNT";
errors[8002] = "NO_TARGET_ACCOUNT";
errors[8003] = "TARGET_IS_SENDER";
errors[8004] = "TRANSFER_NOT_ALLOWED";
errors[8100] = "INSUFFICIENT_SENDER_BALANCE";
errors[8101] = "TRANSFERRED_AMOUNT_TOO_HIGH";

/**
 * Get the error name.
 *
 * If the error number is invalid it returns 'UNKNOWN_ERROR'.
 *
 * 'NO_ERROR' is returned as null string.
 *
 * @param {number} code - The error code.
 * @returns {string} - The name of the error.
 *
 *  @alias module:errors.error
 */
function error(code) {
    if(code === 0){
        return "";
    }
    var err = errors[code];
    if(!err){
        return "UNKNOWN_ERROR";
    }
    return err;
}

exports.error = error;