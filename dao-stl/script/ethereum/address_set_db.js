/**
 * @file address_set_db.js
 * @fileOverview Contract service for the test-contract 'AddressSetDb'.
 * @author Andreas Olofsson (androlo1980@gmail.com)
 * @module address_set_db
 */
"use strict";

var async = require('async');
var util = require('util');

var ContractService = require('../../../script/contract_service');

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
 * @param {Function} cb - error first callback: function(error, added).
 */
AddressSetDb.prototype.addAddress = function (address, cb) {
    var that = this;
    this._contract.addAddress(address, {gas: this._gas}, function(error, txHash){
        if(error) return cb(error);
        that.waitForArgs('AddAddress', txHash, cb);
    });
};

/**
 * Remove an address from the set.
 *
 * @param {string} address - The address.
 * @param {Function} cb - error first callback: function(error, removed).
 */
AddressSetDb.prototype.removeAddress = function (address, cb) {
    var that = this;
    this._contract.removeAddress(address, {gas: this._gas}, function(error, txHash){
        if(error) return cb(error);
        that.waitForArgs('RemoveAddress', txHash, cb);
    });
};

/**
 * Check if an address exists.
 *
 * @param {string} address - The address.
 * @param {Function} cb - error first callback: function(error, has).
 */
AddressSetDb.prototype.hasAddress = function (address, cb) {
    this._contract.hasAddress(address, cb);
};

/**
 * Get an address by its index in the backing array.
 *
 * @param {number} index - The index.
 * @param {Function} cb - error first callback: function(error, address, exists).
 */
AddressSetDb.prototype.addressFromIndex = function (index, cb) {
    this._contract.addressFromIndex(index, function(err, ret) {
        if (err) return cb(err);
        var fmt = afiFormat(ret);
        cb(null, fmt.address, fmt.exists);
    })
};

/**
 * Get the size of the set.
 *
 * @param {Function} cb - error first callback: function(error, numAddresses).
 */
AddressSetDb.prototype.numAddresses = function (cb) {
    this._contract.numAddresses(cb);
};

/**
 * Get values.
 *
 * If neither 'start' nor 'elements' are provided, the entire collection will be fetched.
 *
 * If only one number is found before the callback, it will be used as starting index.
 *
 * @param {number} [start=0] - The starting index.
 * @param {number} [elements] - The number of elements to fetch.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
AddressSetDb.prototype.values = function(start, elements, cb){

    var that = this;

    var block = this._web3.eth.blockNumber;

    this._contract.numAddresses(block, function(error, num){
        if (error) return cb(error);
        var size = num.toNumber();

        var s, e;
        if (typeof(start) === "function") {
            s = 0;
            e = size;
            cb = start;
        }
        else if (typeof(elements) === "function") {
            s = start;
            e = size - start;
            cb = elements;
        }
        else {
            s = start;
            e = start + elements > size ? size : start + elements;
        }

        var addresses = [];
        var i = s;
        async.whilst(
            function () {
                return i < e;
            },
            function (cb) {
                that._contract.addressFromIndex(i, block, function(error, ret){
                    if(error) return cb(error);
                    var fmt = afiFormat(ret);
                    if(fmt.exists)
                        addresses.push(fmt.address);
                    i++;
                    cb();
                });
            },
            function (err) {
                cb(err, addresses);
            }
        );

    });

};

function afiFormat(ret) {
    return {address: ret[0], exists: ret[1]};
}

module.exports = AddressSetDb;