/**
 * @file default_permission.js
 * @fileOverview Contract service for 'DefaultPermission'.
 * @author Andreas Olofsson (androlo1980@gmail.com)
 * @module dao_core/default_permission
 */
"use strict";

var async = require('async');
var util = require('util');

var ContractService = require('../../script/contract_service');
var daoUtils = require('../../script/dao_utils');

/**
 * Service for 'Permission'
 *
 * @param {Object} web3 - A web3 object.
 * @param {Object} contract - A web3 contract instance.
 * @param {number} gas - The amount of gas that will be used in transactions.
 *
 * @constructor
 * @augments module:contract_service:ContractService
 */
function Permission(web3, contract, gas) {
    ContractService.call(this, web3, contract, gas);
}

util.inherits(Permission, ContractService);

/**
 * Set the root address.
 *
 * @param {string} newRoot - The new root address.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
Permission.prototype.setRoot = function (newRoot, cb) {
    var that = this;
    this._contract.setPermission(newRoot, {gas: this._gas}, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('SetRoot', txHash, cb);
    });
};

/**
 * Get the root address.
 *
 * @param {Function} cb - error first callback: function(error, rootAddress).
 */
Permission.prototype.root = function (cb) {
    this._contract.root(cb);
};

/**
 * Get the root data, which includes the address and timestamp when he was added.
 *
 * @param {Function} cb - error first callback: function(error, address, timestamp).
 */
Permission.prototype.rootData = function (cb) {
    this._contract.rootData(function(error, ret){
        if (error) return cb(error);
        var addr = ret[0];
        var time = daoUtils.bnToDate(ret[1]);
        cb(null, addr, time);
    });
};

/**
 * Add a new owner. Owners satisifies 'hasPermission', but can not add or remove other owners.
 *
 * @param {string} address - The owner address.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
Permission.prototype.addOwner = function (address, cb) {
    var that = this;
    this._contract.addOwner(address, {gas: this._gas}, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('AddOwner', txHash, cb);
    });
};

/**
 * Remove an owner.
 *
 * @param {string} address - The owner address.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
Permission.prototype.removeOwner = function (address, cb) {
    var that = this;
    this._contract.removeOwner(address, {gas: this._gas}, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('RemoveOwner', txHash, cb);
    });
};

/**
 * Get the timestamp when an owner was added. Also serves as an existence check.
 *
 * @param {Function} cb - error first callback: function(error, timestamp, errorCode).
 */
Permission.prototype.ownerTimestamp = function (cb) {
    this._contract.ownerTimestamp(function(error, ret){
        if (error) return cb(error);
        var time = daoUtils.bnToDate(ret[0]);
        var code = ret[1].toNumber();
        cb(null, time, code);
    });
};

/**
 * Get an owner's data based on his position in the backing array.
 *
 * @param {number} index - The index.
 * @param {Function} cb - error first callback: function(error, address, timestamp, errorCode).
 */
Permission.prototype.ownerFromIndex = function (index, cb) {
    this._contract.ownerFromIndex(index, function(error, ret){
        if (error) return cb(error);
        var fmt = ofiFormat(ret);
        cb(null, fmt.address, fmt.timestamp, fmt.error);
    });
};

/**
 * Get the total number of owners.
 *
 * @param {Function} cb - error first callback: function(error, numOwners).
 */
Permission.prototype.numOwners = function (cb) {
    this._contract.numOwners(cb);
};

/**
 * Check if an address has this permission, meaning they're either root or an owner.
 *
 * @param {string} address - The address.
 * @param {Function} cb - error first callback: function(error, hasPermission).
 */
Permission.prototype.hasPermission = function (address, cb) {
    this._contract.hasPermission(address, cb);
};


/**
 * Get owners.
 *
 * If neither 'start' nor 'elements' are provided, the entire collection will be fetched.
 *
 * If only one number is found before the callback, it will be used as starting index.
 *
 * @param {number} [start=0] - The starting index.
 * @param {number} [elements] - The number of elements to fetch.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
Permission.prototype.owners = function (start, elements, cb) {

    var that = this;

    var block = this._web3.eth.blockNumber;

    this._contract.numOwners(block, function (error, num) {
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

        var owners = [];
        var i = s;
        async.whilst(
            function () {
                return i < e;
            },
            function (cb) {
                that._contract.ownerFromIndex(i, block, function (error, ret) {
                    if (error) return cb(error);
                    var fmt = ofiFormat(ret);

                    if (fmt.error === 0) {
                        owners.push({address: fmt.address, timestamp: fmt.timestamp});
                    }
                    i++;
                    cb();
                });
            },
            function (err) {
                cb(err, owners);
            }
        );

    });

};

/**
 * Destroy the permission contract.
 *
 * @param {address} fundReceiver - The address that will receive the funds from the contract.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
Permission.prototype.destroy = function (fundReceiver, cb) {
    var that = this;
    this._contract.destroy(fundReceiver, {gas: this._gas}, function(error, txHash){
        if(error) return cb(error);
        that.waitForDestroyed(txHash, cb);
    });
};

function ofiFormat(ret) {
    return {address: ret[0], timestamp: daoUtils.bnToDate(ret[1]), error: ret[2].toNumber()};
}

module.exports = Permission;