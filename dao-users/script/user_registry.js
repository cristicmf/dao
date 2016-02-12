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
 *
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
UserRegistry.prototype.registerUser = function (data, cb) {
    var addr = data.address;
    var nickname = data.nickname;
    var dataHash = data.dataHash;
    var that = this;
    var nickHex = daoUtils.atoh(nickname);
    this._contract.registerUser(addr, nickHex, dataHash, {gas: this._gas}, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('RegisterUser', txHash, cb);
    });
};

/**
 * Register the caller as a user.
 *
 * @param {Object} data - {nickname: <string>, dataHash: <string>}
 *
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
UserRegistry.prototype.registerSelf = function (data, cb) {
    var nickname = data.nickname;
    var dataHash = data.dataHash;
    var that = this;
    var nickHex = daoUtils.atoh(nickname);
    this._contract.registerSelf(nickHex, dataHash, {gas: this._gas}, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('RegisterUser', txHash, cb);
    });
};

/**
 * Remove a user.
 *
 * @param {string} addr - The user address.
 *
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
UserRegistry.prototype.removeUser = function (addr, cb) {
    var that = this;
    this._contract.removeUser(addr, {gas: this._gas}, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('RemoveUser', txHash, cb);
    });
};

/**
 * Remove the caller as a user.
 *
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
UserRegistry.prototype.removeSelf = function (cb) {
    var that = this;
    this._contract.removeSelf({gas: this._gas}, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('RemoveUser', txHash, cb);
    });
};

/**
 * Update a user's data-hash.
 *
 * @param {Object} data - {address: <string>, dataHash: <string>}
 *
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
UserRegistry.prototype.updateDataHash = function (data, cb) {
    var addr = data.address;
    var dataHash = data.dataHash;
    var that = this;
    this._contract.updateDataHash(addr, dataHash, {gas: this._gas}, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('UpdateDataHash', txHash, cb);
    });
};

/**
 * Update the caller's data-hash.
 *
 * @param {string} dataHash - The hash of the file containing user data.
 *
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
UserRegistry.prototype.updateMyDataHash = function (dataHash, cb) {
    var that = this;
    this._contract.updateMyDataHash(dataHash, {gas: this._gas}, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('UpdateDataHash', txHash, cb);
    });
};

/**
 * Set the maximum number of users allowed.
 *
 * @param {number} maxUsers - The maximum number.
 *
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
UserRegistry.prototype.setMaxUsers = function (maxUsers, cb) {
    var that = this;
    this._contract.setMaxUsers(maxUsers, {gas: this._gas}, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('SetMaxUsers', txHash, cb);
    });
};

/**
 * Set the address of the user database contract.
 *
 * @param {string} databaseAddress - The database address.
 *
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
UserRegistry.prototype.setUserDatabase = function (databaseAddress, cb) {
    var that = this;
    this._contract.setUserdatabase(databaseAddress, {gas: this._gas}, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('SetUserDatabase', txHash, cb);
    });
};

/**
 * Get the address of the user database contract.
 *
 * @param {Function} cb - error first callback: function(error, address).
 */
UserRegistry.prototype.userDatabase = function (cb) {
    this._contract.userDatabase(cb);
};

/**
 * Set the admin address.
 *
 * @param {string} adminAddress - The admin address.
 *
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
UserRegistry.prototype.setAdmin = function (adminAddress, cb) {
    var that = this;
    this._contract.setAdmin(adminAddress, {gas: this._gas}, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('SetAdmin', txHash, cb);
    });
};

/**
 * Get the address of the current administrator.
 *
 * @param {Function} cb - error first callback: function(error, address).
 */
UserRegistry.prototype.admin = function (cb) {
    this._contract.admin(cb);
};

module.exports = UserRegistry;