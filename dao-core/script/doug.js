/**
 * @file default_doug.js
 * @fileOverview Contract service for 'DefaultDoug'.
 * @author Andreas Olofsson (androlo1980@gmail.com)
 * @module dao_core/doug
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
 * @param {Object} data - {id: <string>, address: <string>}
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
Doug.prototype.addActionsContract = function (data, txData, cb) {
    var that = this;
    var id = data.id;
    var addr = data.address;
    var idHex = daoUtils.atoh(id);
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.addActionsContract(idHex, addr, txData, function (error, txHash) {
        if (error) return cb(error);
        that.waitFor('AddActionsContract', txHash, cb);
    });
};

/**
 * Remove an actions-contract from the registry.
 *
 * @param {string} identifier - A < 32 byte identifier.
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
Doug.prototype.removeActionsContract = function (identifier, txData, cb) {
    var that = this;
    var idHex = daoUtils.atoh(identifier);
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.removeActionsContract(idHex, txData, function (error, txHash) {
        if (error) return cb(error);
        that.waitFor('RemoveActionsContract', txHash, cb);
    });
};

/**
 * Get an actions-contracts address by its id.
 *
 * @param {string} identifier - A < 32 byte identifier.
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, address).
 */
Doug.prototype.actionsContractAddress = function (identifier, txData, cb) {
    var idHex = daoUtils.atoh(identifier);
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.actionsContractAddress(idHex, txData, cb);
};

/**
 * Get an actions-contracts id by its address.
 *
 * @param {string} address - The contract address.
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, id).
 */
Doug.prototype.actionsContractId = function (address, txData, cb) {
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.actionsContractId(address, txData, function (error, idHex) {
        if (error) return cb(error);
        var id = daoUtils.htoa(idHex);
        cb(null, id);
    });
};

/**
 * Get an actions-contracts data by its index in the backing array.
 *
 * @param {number} index - The index.
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, {identifier: <string>, address: <string>, error: <number>}).
 */
Doug.prototype.actionsContractFromIndex = function (index, txData, cb) {
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.actionsContractFromIndex(index, txData, function (error, ret) {
        if (error) return cb(error);
        var fmt = cfiFormat(ret);
        cb(null, fmt);
    });
};

/**
 * Get the number of registered actions-contracts.
 *
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, numContracts).
 */
Doug.prototype.numActionsContracts = function (txData, cb) {
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.numActionsContracts(txData, cb);
};

/**
 * Set whether or not to call destroy on actions-contracts when they are removed from doug.
 *
 * @param {boolean} destroyRemovedActions - 'true' if contracts should be destroyed.
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
Doug.prototype.setDestroyRemovedActions = function (destroyRemovedActions, txData, cb) {
    var that = this;
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.setDestroyRemovedActions(destroyRemovedActions, txData, function (error, txHash) {
        if (error) return cb(error);
        that.waitFor('SetDestroyRemovedActions', txHash, cb);
    });
};

/**
 * Get whether or not to call destroy on actions-contracts when they are removed from doug.
 *
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, destroyRemovedActions).
 */
Doug.prototype.destroyRemovedActions = function (txData, cb) {
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.destroyRemovedActions(txData, cb);
};

/**
 * Get actions-contracts.
 *
 * If neither 'startIndex' nor 'elements' are provided, the entire collection will be fetched.
 *
 * @param {Object} queryData - {startIndex: <number>, elements: <number>}
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, {startIndex: number, endIndex: number, totalSize: number, blockNumber: block, contracts: contracts}).
 */
Doug.prototype.actionsContracts = function (queryData, txData, cb) {

    var that = this;

    var block = this._web3.eth.blockNumber;

    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);

    this._contract.numActionsContracts(txData, block, function (error, num) {
        if (error) return cb(error);
        var size = num.toNumber();

        var s = 0, e = 0;

        if (queryData && queryData.startIndex)
            s = queryData.startIndex;
        if (queryData && queryData.elements)
            e = start + queryData.elements > size ? size : start + queryData.elements;
        else
            e = size;

        var contracts = [];
        var i = s;
        async.whilst(
            function () {
                return i < e;
            },
            function (cb) {
                that._contract.actionsContractFromIndex(i, txData, block, function (error, ret) {
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
                cb(err, {startIndex: s, endIndex: e, totalSize: size, blockNumber: block, contracts: contracts});
            }
        );

    });

};

// *************************** Database-contracts ***************************

/**
 * Add a database-contract to the registry.
 *
 * @param {Object} data - {id: <string>, address: <string>}
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
Doug.prototype.addDatabaseContract = function (data, txData, cb) {
    var that = this;
    var id = data.id;
    var addr = data.address;
    var idHex = daoUtils.atoh(id);
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.addDatabaseContract(idHex, addr, txData, function (error, txHash) {
        if (error) return cb(error);
        that.waitFor('AddDatabaseContract', txHash, cb);
    });
};

/**
 * Remove a database-contract from the registry.
 *
 * @param {string} identifier - A < 32 byte identifier.
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
Doug.prototype.removeDatabaseContract = function (identifier, txData, cb) {
    var that = this;
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    var idHex = daoUtils.atoh(identifier);
    this._contract.removeDatabaseContract(idHex, txData, function (error, txHash) {
        if (error) return cb(error);
        that.waitFor('RemoveDatabaseContract', txHash, cb);
    });
};

/**
 * Get a database-contracts address by its id.
 *
 * @param {string} identifier - A < 32 byte identifier.
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, address).
 */
Doug.prototype.databaseContractAddress = function (identifier, txData, cb) {
    var idHex = daoUtils.atoh(identifier);
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.databaseContractAddress(idHex, txData, cb);
};

/**
 * Get a database-contracts id by its address.
 *
 * @param {string} address - The contract address.
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, id).
 */
Doug.prototype.databaseContractId = function (address, txData, cb) {
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.databaseContractId(address, txData, function (error, idHex) {
        if (error) return cb(error);
        var id = daoUtils.htoa(idHex);
        cb(null, id);
    });
};

/**
 * Get a database-contracts data by its index in the backing array.
 *
 * @param {number} index - The index.
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, identifier, address, errorCode).
 */
Doug.prototype.databaseContractFromIndex = function (index, txData, cb) {
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.databaseContractFromIndex(index, txData, function (error, ret) {
        if (error) return cb(error);
        cb(null, cfiFormat(ret));
    });
};

/**
 * Get the number of registered database-contracts.
 *
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, numContracts).
 */
Doug.prototype.numDatabaseContracts = function (txData, cb) {
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.numDatabaseContracts(txData, cb);
};

/**
 * Set whether or not to call destroy on database-contracts when they are removed from doug.
 *
 * @param {boolean} destroyRemovedDatabases - 'true' if contracts should be destroyed.
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
Doug.prototype.setDestroyRemovedDatabases = function (destroyRemovedDatabases, txData, cb) {
    var that = this;
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.setDestroyRemovedDatabases(destroyRemovedDatabases, txData, function (error, txHash) {
        if (error) return cb(error);
        that.waitFor('SetDestroyRemovedDatabases', txHash, cb);
    });
};

/**
 * Get whether or not to call destroy on database-contracts when they are removed from doug.
 *
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, destroyRemovedDatabases).
 */
Doug.prototype.destroyRemovedDatabases = function (txData, cb) {
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.destroyRemovedDatabases(txData, cb);
};

/**
 * Get database-contracts.
 *
 * If neither 'startIndex' nor 'elements' are provided, the entire collection will be fetched.
 *
 * @param {Object} queryData - {startIndex: <number>, elements: <number>}
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
Doug.prototype.databaseContracts = function (queryData, txData, cb) {

    var that = this;

    var block = this._web3.eth.blockNumber;

    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);

    this._contract.numDatabaseContracts(txData, block, function (error, num) {
        if (error) return cb(error);
        var size = num.toNumber();

        var s = 0, e = 0;

        if (queryData && queryData.startIndex)
            s = queryData.startIndex;
        if (queryData && queryData.elements)
            e = start + queryData.elements > size ? size : start + queryData.elements;
        else
            e = size;

        var contracts = [];
        var i = s;
        async.whilst(
            function () {
                return i < e;
            },
            function (cb) {
                that._contract.databaseContractFromIndex(i, txData, block, function (error, ret) {
                    if (error) return cb(error);
                    var fmt = cfiFormat(ret);

                    if (fmt.errorCode === 0) {
                        contracts.push({identifier: fmt.identifier, address: fmt.address});
                    }
                    i++;
                    cb();
                });
            },
            function (err) {
                cb(err, {startIndex: s, endIndex: e, totalSize: size, blockNumber: block, contracts: contracts});
            }
        );

    });

};

// *************************** Database-contracts ***************************

/**
 * Set the new permission-contract address.
 *
 * @param {string} permissionAddress - The address.
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, errorCode).
 */
Doug.prototype.setPermission = function (permissionAddress, txData, cb) {
    var that = this;
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.setPermission(permissionAddress, txData, function (error, txHash) {
        if (error) return cb(error);
        that.waitFor('SetPermission', txHash, cb);
    });
};

/**
 * Get the address of the permission-contract.
 *
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, address).
 */
Doug.prototype.permissionAddress = function (txData, cb) {
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.permissionAddress(txData, cb);
};

function cfiFormat(ret) {
    return {identifier: daoUtils.htoa(ret[0]), address: ret[1], error: ret[2].toNumber()};
}

module.exports = Doug;