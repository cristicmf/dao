/**
 * @file address_set_db.js
 * @fileOverview Contract service for the test-contract 'AddressSetDb'.
 * @author Andreas Olofsson (androlo1980@gmail.com)
 * @module address_set_db
 */
"use strict";

var async = require('async');
var util = require('util');

var ContractService = require('../../script/contract_service');

/**
 * Service for 'AddressSetDb'
 *
 * @param {Object} web3 - A web3 object.
 * @param {Object} contract - A web3 contract instance.
 * @param {number} gas - The amount of gas that will be used in transactions.
 *
 * @constructor
 * @augments module:contract_service:ContractService
 */
function AddressSetDb(web3, contract, gas) {
    ContractService.call(this, web3, contract, gas);
}

util.inherits(AddressSetDb, ContractService);

/**
 * Add an address to the set.
 *
 * @param {string} address - The address.
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, added).
 */
AddressSetDb.prototype.addAddress = function (address, txData, cb) {
    var that = this;
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);

    this._contract.addAddress(address, txData, function(error, txHash){
        if(error) return cb(error);
        that.waitForArgs('AddAddress', txHash, cb);
    });
};

/**
 * Remove an address from the set.
 *
 * @param {string} address - The address.
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, removed).
 */
AddressSetDb.prototype.removeAddress = function (address, txData, cb) {
    var that = this;
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);

    this._contract.removeAddress(address, txData, function(error, txHash){
        if(error) return cb(error);
        that.waitForArgs('RemoveAddress', txHash, cb);
    });
};

/**
 * Check if an address exists.
 *
 * @param {string} address - The address.
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, has).
 */
AddressSetDb.prototype.hasAddress = function (address, txData, cb) {
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);

    this._contract.hasAddress(address, txData, cb);
};

/**
 * Get an address by its index in the backing array.
 *
 * @param {number} index - The index.
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, data).
 */
AddressSetDb.prototype.addressFromIndex = function (index, txData, cb) {
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);

    this._contract.addressFromIndex(index, txData, function(err, ret) {
        if (err) return cb(err);
        var fmt = afiFormat(ret);
        cb(null, fmt);
    })
};

/**
 * Get the size of the set.
 *
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, numAddresses).
 */
AddressSetDb.prototype.numAddresses = function (txData, cb) {
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);

    this._contract.numAddresses(txData, cb);
};

/**
 * Get values.
 *
 * If neither 'startIndex' nor 'elements' are provided, the entire collection will be fetched.
 *
 * @param {Object} queryData - {startIndex: <number>, elements: <number>}
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, data).
 */
AddressSetDb.prototype.values = function(queryData, txData, cb){

    var that = this;

    var block = this._web3.eth.blockNumber;

    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);

    this._contract.numAddresses(txData, block, function(error, num){
        if (error) return cb(error);
        var size = num.toNumber();

        var s = 0, e = 0;

        if (queryData && queryData.startIndex)
            s = queryData.startIndex;
        if (queryData && queryData.elements)
            e = start + queryData.elements > size ? size : start + queryData.elements;
        else
            e = size;

        var addresses = [];
        var i = s;
        async.whilst(
            function () {
                return i < e;
            },
            function (cb) {
                that._contract.addressFromIndex(i, txData, block, function(error, ret){
                    if(error) return cb(error);
                    var fmt = afiFormat(ret);
                    if(fmt.exists)
                        addresses.push(fmt.address);
                    i++;
                    cb();
                });
            },
            function (err) {
                cb(err, {startIndex: s, endIndex: e, totalSize: size, blockNumber: block, addresses: addresses});
            }
        );

    });

};

function afiFormat(ret) {
    return {address: ret[0], exists: ret[1]};
}

module.exports = AddressSetDb;