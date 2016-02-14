/**
 * @file currency_database.js
 * @fileOverview Contract service for 'CurrencyDatabase'.
 * @author Andreas Olofsson (androlo1980@gmail.com)
 * @module dao_currency/currency_database
 */
"use strict";

var async = require('async');
var util = require('util');

var ContractService = require('../../script/contract_service');

/**
 * Service for 'CurrencyDatabase'
 *
 * @param {Object} web3 - A web3 object.
 * @param {Object} contract - A web3 contract instance.
 * @param {number} gas - The amount of gas that will be used in transactions.
 *
 * @constructor
 * @augments module:contract_service:ContractService
 */
function CurrencyDatabase(web3, contract, gas) {
    ContractService.call(this, web3, contract, gas);
}

util.inherits(CurrencyDatabase, ContractService);

/**
 * Get the balance of an account.
 *
 * @param {string} addr - The user address.
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, balance).
 */
CurrencyDatabase.prototype.accountBalance = function (addr, txData, cb) {

    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);

    this._contract.accountBalance(addr, txData, cb);
};

module.exports = CurrencyDatabase;