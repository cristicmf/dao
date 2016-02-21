/**
 * @file user_registry.js
 * @fileOverview Contract service for 'UserRegistry'.
 * @author Andreas Olofsson (androlo1980@gmail.com)
 * @module dao_users/user_registry
 */
"use strict";

var util = require('util');

var ContractService = require('../../script/contract_service');
var daoUtils = require('../../script/dao_utils');

/**
 * Service for 'UserRegistry'
 *
 * @param {Object} web3 - A web3 object.
 * @param {Object} contract - A web3 contract instance.
 * @param {number} gas - The amount of gas that will be used in transactions.
 *
 * @constructor
 * @augments module:contract_service:ContractService
 */
function UserRegistry(web3, contract, gas) {
    ContractService.call(this, web3, contract, gas);
}

util.inherits(UserRegistry, ContractService);

/**
 * Register a user.
 *
 * @param {Object} data - {address: <string>, nickname: <string>, dataHash: <string>}
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
UserRegistry.prototype.registerUser = function (data, txData, cb) {
    var addr = data.address;
    var nickname = data.nickname;
    var dataHash = data.dataHash;
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    var that = this;
    var nickHex = daoUtils.atoh(nickname);
    this._contract.registerUser(addr, nickHex, dataHash, txData, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('RegisterUser', txHash, cb);
    });
};

/**
 * Register the caller as a user.
 *
 * @param {Object} data - {nickname: <string>, dataHash: <string>}
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
UserRegistry.prototype.registerSelf = function (data, txData, cb) {
    var nickname = data.nickname;
    var dataHash = data.dataHash;
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    var that = this;
    var nickHex = daoUtils.atoh(nickname);
    this._contract.registerSelf(nickHex, dataHash, txData, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('RegisterUser', txHash, cb);
    });
};

/**
 * Remove a user.
 *
 * @param {string} addr - The user address.
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
UserRegistry.prototype.removeUser = function (addr, txData, cb) {
    var that = this;
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.removeUser(addr, txData, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('RemoveUser', txHash, cb);
    });
};

/**
 * Remove the caller as a user.
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
UserRegistry.prototype.removeSelf = function (txData, cb) {
    var that = this;
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.removeSelf(txData, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('RemoveUser', txHash, cb);
    });
};

/**
 * Update a user's data-hash.
 *
 * @param {Object} data - {address: <string>, dataHash: <string>}
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
UserRegistry.prototype.updateDataHash = function (data, txData, cb) {
    var addr = data.address;
    var dataHash = data.dataHash;
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    var that = this;
    this._contract.updateDataHash(addr, dataHash, txData, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('UpdateDataHash', txHash, cb);
    });
};

/**
 * Set a user property.
 *
 * @param {Object} data - {address: <string>, property: <string>, value: <boolean>}
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
UserRegistry.prototype.updateDataHash = function (data, txData, cb) {
    var addr = data.address;
    var propHex = daoUtils.atoh(data.property);
    var value = data.value;

    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    var that = this;
    this._contract.setProperty(addr, propHex, value, txData, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('SetProperty', txHash, cb);
    });
};

/**
 * Update the caller's data-hash.
 *
 * @param {string} dataHash - The hash of the file containing user data.
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
UserRegistry.prototype.updateMyDataHash = function (dataHash, txData, cb) {
    var that = this;
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.updateMyDataHash(dataHash, txData, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('UpdateDataHash', txHash, cb);
    });
};

/**
 * Set the maximum number of users allowed.
 *
 * @param {number} maxUsers - The maximum number.
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
UserRegistry.prototype.setMaxUsers = function (maxUsers, txData, cb) {
    var that = this;
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.setMaxUsers(maxUsers, txData, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('SetMaxUsers', txHash, cb);
    });
};

/**
 * Set the address of the user database contract.
 *
 * @param {string} databaseAddress - The database address.
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
UserRegistry.prototype.setUserDatabase = function (databaseAddress, txData, cb) {
    var that = this;
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.setUserdatabase(databaseAddress, txData, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('SetUserDatabase', txHash, cb);
    });
};

/**
 * Get the address of the user database contract.
 *
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, address).
 */
UserRegistry.prototype.userDatabase = function (txData, cb) {
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.userDatabase(txData, cb);
};

/**
 * Set the admin address.
 *
 * @param {string} adminAddress - The admin address.
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
UserRegistry.prototype.setAdmin = function (adminAddress, txData, cb) {
    var that = this;
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.setAdmin(adminAddress, txData, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('SetAdmin', txHash, cb);
    });
};

/**
 * Get the address of the current administrator.
 *
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, address).
 */
UserRegistry.prototype.admin = function (txData, cb) {
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.admin(txData, cb);
};

module.exports = UserRegistry;