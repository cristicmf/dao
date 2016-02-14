/**
 * @file contract_service.js
 * @fileOverview Base class for contract services.
 * @author Andreas Olofsson (androlo1980@gmail.com)
 * @module contract_service
 */
'use strict';

/**
 * ContractService is a base class for contract services.
 *
 * @param {Object} web3 - A web3 object.
 * @param {Object} contract - A web3 contract instance.
 * @param {number} gas - The amount of gas that will be used in transactions.
 *
 * @constructor
 */
function ContractService(web3, contract, gas) {
    this._web3 = web3;
    this._contract = contract;
    this._gas = gas;
}

/**
 * Destroy the contract.
 *
 * @param {address} fundReceiver - The address that will receive the funds from the contract.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
ContractService.prototype.destroy = function (fundReceiver, cb) {
    var that = this;
    this._contract.destroy(fundReceiver, {gas: this._gas}, function(error, txHash){
        if(error) return cb(error);
        that.waitForDestroyed(txHash, cb);
    });
};

/**
 * Wait for a transaction to complete. This is implemented by adding events to contracts
 * that will trigger when execution is done - no matter the outcome. The function also has
 * a timeout (default length is 2 minutes) in case there is no response.
 *
 * this function will pass the event arguments back in the callback.
 *
 * @param {string} eventName - The name of the event as it appears in the ABI (no params, just the name).
 * @param {string} txHash - The transaction hash. This is returned from transactions, and is used to filter events.
 * @param cb - The error-first callback. Returns the event arguments.
 */
ContractService.prototype.waitForArgs = function(eventName, txHash, cb){
    var event;

    try {
        event = this._contract[eventName]();
    } catch (error) {
        return cb(error);
    }

    event.watch(function(error, data){
        if (error) return cb(error);
        if(txHash === data.transactionHash) {
            if (timeout) clearTimeout(timeout);
            event.stopWatching();
            cb(null, data.args);
        }
    });

    var timeout = setTimeout(function(){
        event.stopWatching();
        return cb(new Error("Timed out waiting for event"));
    } , 120000);
};

/**
 * Wait for a transaction to complete. This is implemented by adding events to contracts
 * that will trigger when execution is done - no matter the outcome. The function also has
 * a timeout (default length is 2 minutes) in case there is no response.
 *
 * this function will pass the error code from the event arguments back in the callback.
 *
 * @param {string} eventName - The name of the event as it appears in the ABI (no params, just the name).
 * @param {string} txHash - The transaction hash. This is returned from transactions, and is used to filter events.
 * @param cb - The error-first callback. Returns the event 'error' argument as a javascript number.
 */
ContractService.prototype.waitFor = function(eventName, txHash, cb){
    var event;

    try {
        event = this._contract[eventName]();
    } catch (error) {
        return cb(error);
    }

    event.watch(function(error, data){
        if (error) return cb(error);
        if(txHash === data.transactionHash) {
            if (timeout) clearTimeout(timeout);
            event.stopWatching();
            cb(null, data.args.error.toNumber());
        }
    });

    var timeout = setTimeout(function(){
        event.stopWatching();
        return cb(new Error("Timed out waiting for event"));
    } , 120000);
};

/**
 * Wait for a transaction to complete. This is implemented by adding events to contracts
 * that will trigger when execution is done - no matter the outcome. The function also has
 * a timeout (default length is 2 minutes) in case there is no response.
 *
 * Unlike the other 'waitFor' functions, this one takes no 'eventName' param. Instead it uses
 * the 'Destroy' event (which is available in most framework contracts).
 *
 * This function will pass the error code from the event arguments back in the callback. If
 * the error code is 0 it will also call the client to check if the contract was indeed removed
 * (by doing a 'web3.eth.getCode' call to the client).
 *
 * @param {string} txHash - The transaction hash. This is returned from transactions, and is used to filter events.
 * @param cb - The error-first callback. Returns the event 'error' argument as a javascript number.
 */
ContractService.prototype.waitForDestroyed = function(txHash, cb){
    var event;

    try {
        event = this._contract.Destroy();
    } catch (error) {
        return cb(error);
    }
    var that = this;
    event.watch(function(error, data){
        if (error) return cb(error);
        if(txHash === data.transactionHash) {
            if (timeout) clearTimeout(timeout);
            event.stopWatching();
            var code = data.args.error.toNumber();
            if (code !== 0) {
                return cb(null, code);
            }
            that._web3.eth.getCode(that._contract.address, function(error, code){
                if(error) return cb(error);
                if (code !== "0x") {
                    return cb(new Error("Account not destroyed after contract destroy event was fired."));
                }
                cb(null, 0);
            });
        }
    });

    var timeout = setTimeout(function(){
        event.stopWatching();
        return cb(new Error("Timed out waiting for event"));
    } , 120000);
};

ContractService.prototype.contract = function() {
    return this._contract;
};

ContractService.prototype.address = function() {
    return this._contract.address;
};

ContractService.prototype.web3 = function() {
    return this._web3;
};

ContractService.prototype._txData = function(txData) {
    if(!txData) {
        txData = {gas: this._gas};
    }
    else if (!txData.gas) {
        txData.gas = this._gas;
    }
    return txData;
};

module.exports = ContractService;