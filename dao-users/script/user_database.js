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
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, data).
 */
UserDatabase.prototype.userFromAddress = function (addr, txData, cb) {
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.user['address'](addr, txData, function (err, ret) {
        if (err) return cb(err);
        var data = {nickname: daoUtils.htoa(ret[0]), timestamp: daoUtils.bnToDate(ret[1]), dataHash: ret[2]};
        cb(null, data);
    });
};

/**
 * Get user data from the user (nick) name.
 *
 * @param {string} name - The name.
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, data).
 */
UserDatabase.prototype.userFromName = function (name, txData, cb) {
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    var nameHex = daoUtils.atoh(name);
    this._contract.user['bytes32'](nameHex, txData, function (err, ret) {
        var data = {nickname: daoUtils.htoa(ret[0]), timestamp: daoUtils.bnToDate(ret[1]), dataHash: ret[2]};
        cb(null, data);
    });
};

/**
 * Check if an address belongs to a registered user.
 *
 * @param {string} addr - The address.
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, result).
 */
UserDatabase.prototype.hasUserFromAddress = function (addr, txData, cb) {
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.user['address'](addr, txData, cb);
};

/**
 * Check if a name belongs to a registered user.
 *
 * @param {string} name - The name.
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, result).
 */
UserDatabase.prototype.hasUserFromName = function (name, txData, cb) {
    var nameHex = daoUtils.atoh(name);
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.user['bytes32'](nameHex, txData, cb);
};

/**
 * Get a user address from their index in the backing array.
 *
 * @param {number} index - The index.
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, data).
 */
UserDatabase.prototype.userAddressFromIndex = function (index, txData, cb) {
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.userAddressFromIndex(index, txData, function (err, ret) {
        if (err) return cb(err);
        cb(null, {address: ret[0], errorCode: ret[1].toNumber});
    });
};

/**
 * Get user data from their index in the backing array.
 *
 * @param {number} index - The index.
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, data).
 */
UserDatabase.prototype.userFromIndex = function (index, txData, cb) {
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.userFromIndex(index, txData, function (err, ret) {
        if (err) return cb(err);
        var fmt = ufiFormat(ret);
        cb(null, fmt);
    });
};

/**
 * Get the current size of the user database (the number of registered users).
 *
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, size).
 */
UserDatabase.prototype.size = function (txData, cb) {
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.size(txData, cb);
};

/**
 * Get the maximum size of the user database.
 *
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, maxSize).
 */
UserDatabase.prototype.maxSize = function (txData, cb) {
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.maxSize(txData, cb);
};

/**
 * Get users.
 *
 * If neither 'startIndex' nor 'elements' are provided, the entire collection will be fetched.
 *
 * @param {Object} queryData - {startIndex: <number>, elements: <number>}
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, data).
 */
UserDatabase.prototype.users = function (queryData, txData, cb) {

    var that = this;

    var block = this._web3.eth.blockNumber;

    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);

    this._contract.size(txData, block, function (error, num) {
        if (error) return cb(error);
        var size = num.toNumber();

        var s = 0, e = 0;

        if (queryData && queryData.startIndex)
            s = queryData.startIndex;
        if (queryData && queryData.elements)
            e = start + queryData.elements > size ? size : start + queryData.elements;
        else
            e = size;

        var users = [];
        var i = s;
        async.whilst(
            function () {
                return i < e;
            },
            function (cb) {
                that._contract.userFromIndex(i, txData, block, function (error, ret) {
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