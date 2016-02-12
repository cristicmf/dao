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
 *
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
MintedCurrency.prototype.mint = function (data, cb) {
    var that = this;
    var receiver = data.receiver;
    var amount = data.amount;
    this._contract.mint(receiver, amount, {gas: this._gas}, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('Mint', txHash, cb);
    });
};

/**
 * Send coins to a receiver account. Uses caller address as sender.
 *
 * @param {Object} data - {receiver: <string>, amount: <string>}
 *
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
MintedCurrency.prototype.sendSelf = function (data, cb) {
    var that = this;
    var receiver = data.receiver;
    var amount = data.amount;
    this._contract.send['address,uint'](receiver, amount, {gas: this._gas}, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('Send', txHash, cb);
    });
};

/**
 * Send coins from the sender account to a receiver account.
 *
 * @param {Object} data - {sender: <string>, receiver: <string>, amount: <string>}
 *
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
MintedCurrency.prototype.send = function (data, cb) {
    var that = this;
    var sender = data.sender;
    var receiver = data.receiver;
    var amount = data.amount;
    this._contract.send['address,address,uint'](sender, receiver, amount, {gas: this._gas}, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('Send', txHash, cb);
    });
};

/**
 * Set the address of the user currency contract.
 *
 * @param {string} currencyAddress - The currency database address.
 *
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
MintedCurrency.prototype.setCurrencyDatabase = function (currencyAddress, cb) {
    var that = this;
    this._contract.setCurrencyDatabase(currencyAddress, {gas: this._gas}, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('SetCurrencyDatabase', txHash, cb);
    });
};

/**
 * Get the address of the currency database contract.
 *
 * @param {Function} cb - error first callback: function(error, address).
 */
MintedCurrency.prototype.currencyDatabase = function (cb) {
    this._contract.currencyDatabase(cb);
};

/**
 * Set the minter address.
 *
 * @param {string} minterAddress - The admin address.
 *
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
MintedCurrency.prototype.setMinter = function (minterAddress, cb) {
    var that = this;
    this._contract.setMinter(minterAddress, {gas: this._gas}, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('SetMinter', txHash, cb);
    });
};

/**
 * Get the address of the current minter.
 *
 * @param {Function} cb - error first callback: function(error, address).
 */
MintedCurrency.prototype.minter = function (cb) {
    this._contract.minter(cb);
};