/**
 * @file default_doug.js
 * @fileOverview Contract service for 'DefaultDoug'.
 * @author Andreas Olofsson (androlo1980@gmail.com)
 * @module dao_core/default_doug
 */
"use strict";

var async = require('async');
var util = require('util');

var ContractService = require('../../script/contract_service');
var daoUtils = require('../../script/dao_utils');

/**
 * Service for 'Doug'
 *
 * @param {Object} web3 - A web3 object.
 * @param {Object} contract - A web3 contract instance.
 * @param {number} gas - The amount of gas that will be used in transactions.
 *
 * @constructor
 * @augments module:contract_service:ContractService
 */
function Doug(web3, contract, gas) {
    ContractService.call(this, web3, contract, gas);
}

util.inherits(Doug, ContractService);

// *************************** Actions-contracts ***************************

/**
 * Add an actions-contract to the registry.
 *
 * @param {string} identifier - A < 32 byte identifier.
 * @param {string} address - The contract address.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
Doug.prototype.addActionsContract = function (identifier, address, cb) {
    var that = this;
    var idHex = daoUtils.atoh(identifier);
    this._contract.addActionsContract(idHex, address, {gas: this._gas}, function (error, txHash) {
        if (error) return cb(error);
        that.waitFor('AddActionsContract', txHash, cb);
    });
};

/**
 * Remove an actions-contract from the registry.
 *
 * @param {string} identifier - A < 32 byte identifier.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
Doug.prototype.removeActionsContract = function (identifier, cb) {
    var that = this;
    var idHex = daoUtils.atoh(identifier);
    this._contract.removeActionsContract(idHex, {gas: this._gas}, function (error, txHash) {
        if (error) return cb(error);
        that.waitFor('RemoveActionsContract', txHash, cb);
    });
};

/**
 * Get an actions-contracts address by its id.
 *
 * @param {string} identifier - A < 32 byte identifier.
 * @param {Function} cb - error first callback: function(error, address).
 */
Doug.prototype.actionsContractAddress = function (identifier, cb) {
    var idHex = daoUtils.atoh(identifier);
    this._contract.actionsContractAddress(idHex, cb);
};

/**
 * Get an actions-contracts id by its address.
 *
 * @param {string} address - The contract address.
 * @param {Function} cb - error first callback: function(error, id).
 */
Doug.prototype.actionsContractId = function (address, cb) {
    this._contract.actionsContractId(address, function (error, idHex) {
        if (error) return cb(error);
        var id = daoUtils.htoa(idHex);
        cb(null, id);
    });
};

/**
 * Get an actions-contracts data by its index in the backing array.
 *
 * @param {number} index - The index.
 * @param {Function} cb - error first callback: function(error, identifier, address, errorCode).
 */
Doug.prototype.actionsContractFromIndex = function (index, cb) {
    this._contract.actionsContractFromIndex(index, function (error, ret) {
        if (error) return cb(error);
        var fmt = cfiFormat(ret);
        cb(null, fmt.identifier, fmt.address, fmt.error);
    });
};

/**
 * Get the number of registered actions-contracts.
 *
 * @param {Function} cb - error first callback: function(error, numContracts).
 */
Doug.prototype.numActionsContracts = function (cb) {
    this._contract.numActionsContracts(cb);
};

/**
 * Set whether or not to call destroy on actions-contracts when they are removed from doug.
 *
 * @param {boolean} destroyRemovedActions - 'true' if contracts should be destroyed.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
Doug.prototype.setDestroyRemovedActions = function (destroyRemovedActions, cb) {
    var that = this;
    this._contract.setDestroyRemovedActions(destroyRemovedActions, {gas: this._gas}, function (error, txHash) {
        if (error) return cb(error);
        that.waitFor('SetDestroyRemovedActions', txHash, cb);
    });
};

/**
 * Get whether or not to call destroy on actions-contracts when they are removed from doug.
 *
 * @param {Function} cb - error first callback: function(error, destroyRemovedActions).
 */
Doug.prototype.destroyRemovedActions = function (cb) {
    this._contract.destroyRemovedActions(cb);
};

/**
 * Get actions-contracts.
 *
 * If neither 'start' nor 'elements' are provided, the entire collection will be fetched.
 *
 * If only one number is found before the callback, it will be used as starting index.
 *
 * @param {number} [start=0] - The starting index.
 * @param {number} [elements] - The number of elements to fetch.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
Doug.prototype.actionsContracts = function (start, elements, cb) {

    var that = this;

    var block = this._web3.eth.blockNumber;

    this._contract.numActionsContracts(block, function (error, num) {
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

        var contracts = [];
        var i = s;
        async.whilst(
            function () {
                return i < e;
            },
            function (cb) {
                that._contract.actionsContractFromIndex(i, block, function (error, ret) {
                    if (error) return cb(error);
                    var fmt = cfiFormat(ret);

                    if (fmt.error === 0) {
                        contracts.push({identifier: fmt.identifier, address: fmt.address});
                    }
                    i++;
                    cb();
                });
            },
            function (err) {
                cb(err, contracts);
            }
        );

    });

};

// *************************** Database-contracts ***************************

/**
 * Add a database-contract to the registry.
 *
 * @param {string} identifier - A < 32 byte identifier.
 * @param {string} address - The contract address.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
Doug.prototype.addDatabaseContract = function (identifier, address, cb) {
    var that = this;
    var idHex = daoUtils.atoh(identifier);
    this._contract.addDatabaseContract(idHex, address, {gas: this._gas}, function (error, txHash) {
        if (error) return cb(error);
        that.waitFor('AddDatabaseContract', txHash, cb);
    });
};

/**
 * Remove a database-contract from the registry.
 *
 * @param {string} identifier - A < 32 byte identifier.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
Doug.prototype.removeDatabaseContract = function (identifier, cb) {
    var that = this;
    var idHex = daoUtils.atoh(identifier);
    this._contract.removeDatabaseContract(idHex, {gas: this._gas}, function (error, txHash) {
        if (error) return cb(error);
        that.waitFor('RemoveDatabaseContract', txHash, cb);
    });
};

/**
 * Get a database-contracts address by its id.
 *
 * @param {string} identifier - A < 32 byte identifier.
 * @param {Function} cb - error first callback: function(error, address).
 */
Doug.prototype.databaseContractAddress = function (identifier, cb) {
    var idHex = daoUtils.atoh(identifier);
    this._contract.databaseContractAddress(idHex, cb);
};

/**
 * Get a database-contracts id by its address.
 *
 * @param {string} address - The contract address.
 * @param {Function} cb - error first callback: function(error, id).
 */
Doug.prototype.databaseContractId = function (address, cb) {
    this._contract.databaseContractId(address, function (error, idHex) {
        if (error) return cb(error);
        var id = daoUtils.htoa(idHex);
        cb(null, id);
    });
};

/**
 * Get a database-contracts data by its index in the backing array.
 *
 * @param {number} index - The index.
 * @param {Function} cb - error first callback: function(error, identifier, address, errorCode).
 */
Doug.prototype.databaseContractFromIndex = function (index, cb) {
    this._contract.databaseContractFromIndex(index, function (error, ret) {
        if (error) return cb(error);
        var fmt = cfiFormat(ret);
        cb(null, fmt.identifier, fmt.address, fmt.error);
    });
};

/**
 * Get the number of registered database-contracts.
 *
 * @param {Function} cb - error first callback: function(error, numContracts).
 */
Doug.prototype.numDatabaseContracts = function (cb) {
    this._contract.numDatabaseContracts(cb);
};

/**
 * Set whether or not to call destroy on database-contracts when they are removed from doug.
 *
 * @param {boolean} destroyRemovedDatabases - 'true' if contracts should be destroyed.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
Doug.prototype.setDestroyRemovedDatabases = function (destroyRemovedDatabases, cb) {
    var that = this;
    this._contract.setDestroyRemovedDatabases(destroyRemovedDatabases, {gas: this._gas}, function (error, txHash) {
        if (error) return cb(error);
        that.waitFor('SetDestroyRemovedDatabases', txHash, cb);
    });
};

/**
 * Get whether or not to call destroy on database-contracts when they are removed from doug.
 *
 * @param {Function} cb - error first callback: function(error, destroyRemovedDatabases).
 */
Doug.prototype.destroyRemovedDatabases = function (cb) {
    this._contract.destroyRemovedDatabases(cb);
};

/**
 * Get database-contracts.
 *
 * If neither 'start' nor 'elements' are provided, the entire collection will be fetched.
 *
 * If only one number is found before the callback, it will be used as starting index.
 *
 * @param {number} [start=0] - The starting index.
 * @param {number} [elements] - The number of elements to fetch.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
Doug.prototype.databaseContracts = function (start, elements, cb) {

    var that = this;

    var block = this._web3.eth.blockNumber;

    this._contract.numDatabaseContracts(block, function (error, num) {
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

        var contracts = [];
        var i = s;
        async.whilst(
            function () {
                return i < e;
            },
            function (cb) {
                that._contract.databaseContractFromIndex(i, block, function (error, ret) {
                    if (error) return cb(error);
                    var fmt = cfiFormat(ret);

                    if (fmt.error === 0) {
                        contracts.push({identifier: fmt.identifier, address: fmt.address});
                    }
                    i++;
                    cb();
                });
            },
            function (err) {
                cb(err, contracts);
            }
        );

    });

};

// *************************** Database-contracts ***************************

/**
 * Set the new permission-contract address.
 *
 * @param {string} permissionAddress - The address.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
Doug.prototype.setPermission = function (permissionAddress, cb) {
    var that = this;
    this._contract.setPermission(permissionAddress, {gas: this._gas}, function (error, txHash) {
        if (error) return cb(error);
        that.waitFor('SetPermission', txHash, cb);
    });
};

/**
 * Get the address of the permission-contract.
 *
 * @param {Function} cb - error first callback: function(error, address).
 */
Doug.prototype.permissionAddress = function (cb) {
    this._contract.permissionAddress(cb);
};

/**
 * Destroy the doug contract.
 *
 * @param {address} fundReceiver - The address that will receive the funds from the contract.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
Doug.prototype.destroy = function (fundReceiver, cb) {
    var that = this;
    this._contract.destroy(fundReceiver, {gas: this._gas}, function (error, txHash) {
        if (error) return cb(error);
        that.waitForDestroyed(txHash, cb);
    });
};

function cfiFormat(ret) {
    return {identifier: daoUtils.htoa(ret[0]), address: ret[1], error: ret[2]};
}

module.exports = Doug;