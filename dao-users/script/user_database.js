/**
 * @file user_database.js
 * @fileOverview Contract service for 'UserDatabase'.
 * @author Andreas Olofsson (androlo1980@gmail.com)
 * @module dao_users/user_database
 */
"use strict";

var async = require('async');
var util = require('util');

var ContractService = require('../../script/contract_service');
var daoUtils = require('../../script/dao_utils');

/**
 * Service for 'UserDatabase'
 *
 * @param {Object} web3 - A web3 object.
 * @param {Object} contract - A web3 contract instance.
 * @param {number} gas - The amount of gas that will be used in transactions.
 *
 * @constructor
 * @augments module:contract_service:ContractService
 */
function UserDatabase(web3, contract, gas) {
    ContractService.call(this, web3, contract, gas);
}

util.inherits(UserDatabase, ContractService);

/**
 * Get user data from the user address.
 *
 * @param {string} addr - The address.
 * @param {Function} cb - error first callback: function(error, nickname, time, dataHash).
 */
UserDatabase.prototype.userFromAddress = function (addr, cb) {
    this._contract.user['address'](addr, function(err, ret){
        if(err) return cb(err);
        var nickname = daoUtils.htoa(ret[0]);
        var time = daoUtils.bnToDate(ret[1]);
        var dataHash = ret[2];
        cb(null, nickname, time, dataHash)
    });
};

/**
 * Get user data from the user (nick) name.
 *
 * @param {string} name - The name.
 * @param {Function} cb - error first callback: function(error, nickname, time, dataHash).
 */
UserDatabase.prototype.userFromName = function (name, cb) {
    var nameHex = daoUtils.atoh(name);
    this._contract.user['bytes32'](nameHex, function(err, ret){
        if(err) return cb(err);
        var nickname = daoUtils.htoa(ret[0]);
        var time = daoUtils.bnToDate(ret[1]);
        var dataHash = ret[2];
        cb(null, nickname, time, dataHash)
    });
};

/**
 * Check if an address belongs to a registered user.
 *
 * @param {string} addr - The address.
 * @param {Function} cb - error first callback: function(error, rootAddress).
 */
UserDatabase.prototype.hasUserFromAddress = function (addr, cb) {
    this._contract.user['address'](addr, cb);
};

/**
 * Check if a name belongs to a registered user.
 *
 * @param {string} name - The name.
 * @param {Function} cb - error first callback: function(error, rootAddress).
 */
UserDatabase.prototype.hasUserFromName = function (name, cb) {
    var nameHex = daoUtils.atoh(name);
    this._contract.user['bytes32'](nameHex, cb);
};

/**
 * Get a user address from their index in the backing array.
 *
 * @param {number} index - The index.
 * @param {Function} cb - error first callback: function(error, address, errorCode).
 */
UserDatabase.prototype.userAddressFromIndex = function (index, cb) {
    this._contract.userAddressFromIndex(index, function(err, ret){
        if(err) return cb(err);
        var addr = ret[0];
        var code = ret[1].toNumber();
        cb(null, addr, code);
    });
};

/**
 * Get user data from their index in the backing array.
 *
 * @param {number} index - The index.
 * @param {Function} cb - error first callback: function(error, address, nickname, timestamp, dataHash, errorCode).
 */
UserDatabase.prototype.userFromIndex = function (index, cb) {
    this._contract.userFromIndex(index, function(err, ret){
        if(err) return cb(err);
        var fmt = ufiFormat(ret);
        cb(null, fmt.address, fmt.nickname, fmt.timestamp, fmt.dataHash, fmt.errorCode);
    });
};

/**
 * Get the current size of the user database (the number of registered users).
 *
 * @param {Function} cb - error first callback: function(error, size).
 */
UserDatabase.prototype.size = function (cb) {
    this._contract.size(cb);
};

/**
 * Get the maximum size of the user database.
 *
 * @param {Function} cb - error first callback: function(error, maxSize).
 */
UserDatabase.prototype.maxSize = function (cb) {
    this._contract.maxSize(cb);
};

/**
 * Get users.
 *
 * If neither 'start' nor 'elements' are provided, the entire collection will be fetched.
 *
 * If only one number is found before the callback, it will be used as starting index.
 *
 * @param {number} [start=0] - The starting index.
 * @param {number} [elements] - The number of elements to fetch.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
UserDatabase.prototype.users = function (start, elements, cb) {

    var that = this;

    var block = this._web3.eth.blockNumber;

    this._contract.size(block, function (error, num) {
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

        var users = [];
        var i = s;
        async.whilst(
            function () {
                return i < e;
            },
            function (cb) {
                that._contract.userFromIndex(i, block, function (error, ret) {
                    if (error) return cb(error);
                    var fmt = ufiFormat(ret);

                    if (fmt.error === 0) {
                        users.push({
                            address: fmt.address,
                            nickname: fmt.nickname,
                            timestamp: fmt.timestamp,
                            dataHash: fmt.dataHash,
                            errorCode: fmt.errorCode
                        });
                    }
                    i++;
                    cb();
                });
            },
            function (err) {
                cb(err, {startIndex: s, endIndex: e, totalSize: size, blockNumber: block, users: users});
            }
        );

    });

};

function ufiFormat(ret) {
    return {
        address: ret[0],
        nickname: daoUtils.htoa(ret[1]),
        timestamp: daoUtils.bnToDate(ret[2]),
        dataHash: ret[3],
        errorCode: ret[2].toNumber()
    };
}

module.exports = UserDatabase;