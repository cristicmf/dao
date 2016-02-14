/**
 * @file user_registry.js
 * @fileOverview Contract service for 'MintedCurrency'.
 * @author Andreas Olofsson (androlo1980@gmail.com)
 * @module dao_currency/minted_currency
 */
"use strict";

var util = require('util');

var ContractService = require('../../script/contract_service');

/**
 * Service for 'MintedCurrency'
 *
 * @param {Object} web3 - A web3 object.
 * @param {Object} contract - A web3 contract instance.
 * @param {number} gas - The amount of gas that will be used in transactions.
 *
 * @constructor
 * @augments module:contract_service:ContractService
 */
function MintedCurrency(web3, contract, gas) {
    ContractService.call(this, web3, contract, gas);
}

util.inherits(MintedCurrency, ContractService);

/**
 * Mint coins and add to an account.
 *
 * @param {Object} data - {receiver: <string>, amount: <string>}
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
MintedCurrency.prototype.mint = function (data, txData, cb) {
    var that = this;
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    var receiver = data.receiver;
    var amount = data.amount;
    this._contract.mint(receiver, amount, txData, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('Mint', txHash, cb);
    });
};

/**
 * Send coins to a receiver account. Uses caller address as sender.
 *
 * @param {Object} data - {receiver: <string>, amount: <string>}
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
MintedCurrency.prototype.sendSelf = function (data, txData, cb) {
    var that = this;
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    var receiver = data.receiver;
    var amount = data.amount;
    this._contract.send['address,uint'](receiver, amount, txData, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('Send', txHash, cb);
    });
};

/**
 * Send coins from the sender account to a receiver account.
 *
 * @param {Object} data - {sender: <string>, receiver: <string>, amount: <string>}
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
MintedCurrency.prototype.send = function (data, txData,  cb) {
    var that = this;
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    var sender = data.sender;
    var receiver = data.receiver;
    var amount = data.amount;
    this._contract.send['address,address,uint'](sender, receiver, amount, txData, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('Send', txHash, cb);
    });
};

/**
 * Set the address of the user currency contract.
 *
 * @param {string} currencyAddress - The currency database address.
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
MintedCurrency.prototype.setCurrencyDatabase = function (currencyAddress, txData, cb) {
    var that = this;
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.setCurrencyDatabase(currencyAddress, txData, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('SetCurrencyDatabase', txHash, cb);
    });
};

/**
 * Get the address of the currency database contract.
 *
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, address).
 */
MintedCurrency.prototype.currencyDatabase = function (txData, cb) {
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.currencyDatabase(txData, cb);
};

/**
 * Set the minter address.
 *
 * @param {string} minterAddress - The admin address.
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
MintedCurrency.prototype.setMinter = function (minterAddress, txData, cb) {
    var that = this;
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.setMinter(minterAddress, txData, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('SetMinter', txHash, cb);
    });
};

/**
 * Get the address of the current minter.
 *
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, address).
 */
MintedCurrency.prototype.minter = function (txData, cb) {
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.minter(txData, cb);
};