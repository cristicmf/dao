/**
 * @file errors.js
 * @fileOverview Javascript for interpreting error codes. These are the codes used in the Errors.sol contract.
 * @author Andreas Olofsson (androlo1980@gmail.com)
 * @module errors
 */
'use strict';

var errors = {};

errors[0] = {contract: "NO_ERROR", http: 200};
errors[1] = {contract: "ERROR", http: 500};

// ********************** Resources **********************
errors[1000] = {contract: "RESOURCE_ERROR", http: 400};
errors[1001] = {contract: "RESOURCE_NOT_FOUND", http: 404};
errors[1002] = {contract: "RESOURCE_ALREADY_EXISTS", http: 409};

// ********************** Access **********************
errors[2000] = {contract: "ACCESS_DENIED", http: 403};

// ********************** Input **********************
errors[3000] = {contract: "PARAMETER_ERROR", http: 400};
errors[3001] = {contract: "INVALID_PARAM_VALUE", http: 400};
errors[3002] = {contract: "NULL_PARAM_NOT_ALLOWED", http: 400};
errors[3003] = {contract: "INTEGER_OUT_OF_BOUNDS", http: 400};
errors[3100] = {contract: "ARRAY_INDEX_OUT_OF_BOUNDS", http: 400};

// ********************** Contract states *******************
errors[4000] = {contract: "INVALID_STATE", http: 500};

// ********************** Transfers *******************
errors[8000] = {contract: "TRANSFER_FAILED", http: 500};
errors[8001] = {contract: "NO_SENDER_ACCOUNT", http: 404};
errors[8002] = {contract: "NO_TARGET_ACCOUNT", http: 404};
errors[8003] = {contract: "TARGET_IS_SENDER", http: 400};
errors[8004] = {contract: "TRANSFER_NOT_ALLOWED", http: 403};
errors[8100] = {contract: "INSUFFICIENT_SENDER_BALANCE", http: 500};
errors[8101] = {contract: "TRANSFERRED_AMOUNT_TOO_HIGH", http: 500};

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
 * @alias module:errors.error
 */
function error(code) {
    if(code === 0){
        return "";
    }
    var err = errors[code].contract;
    if(!err){
        return "ERROR_UNKNOWN";
    }
    return err;
}

/**
 * Gets an http error code and the contract error name.
 *
 * @param {number} code - The error code.
 * @returns {Object} An object on the form {statusCode: <number>, message: <message>}
 */
function toHttp(code) {
    var cErr = errors[code].contract;
    if(cErr){
        return {statusCode: errors[code].http, message: "Contract execution error: " + cErr};
    } else {
        return {statusCode: 500, message: "Contract execution error: " + "ERROR_UNKNOWN"}
    }
}

exports.error = error;

exports.toHttpError = toHttp;