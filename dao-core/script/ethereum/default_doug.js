var async = require('async');
var util = require('util');

var ContractService = require('../../../script/contract_service');
var daoUtils = require('../../../script/dao_utils');

function DefaultDoug(web3, contract, gas) {
    ContractService.call(this, web3, contract, gas);
}

util.inherits(DefaultDoug, ContractService);

// Actions-contracts

DefaultDoug.prototype.addActionsContract = function (identifier, address, cb) {
    var that = this;
    var idHex = daoUtils.atoh(identifier);
    this._contract.addActionsContract(idHex, address, {gas: this._gas}, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('AddActionsContract', txHash, cb);
    });
};

DefaultDoug.prototype.removeActionsContract = function (identifier, cb) {
    var that = this;
    var idHex = daoUtils.atoh(identifier);
    this._contract.removeActionsContract(idHex, {gas: this._gas}, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('RemoveActionsContract', txHash, cb);
    });
};

DefaultDoug.prototype.actionsContractAddress = function (identifier, cb) {
    var idHex = daoUtils.atoh(identifier);
    this._contract.actionsContractAddress(idHex, cb);
};

DefaultDoug.prototype.actionsContractId = function (address, cb) {
    this._contract.actionsContractId(address, function(error, idHex){
        if(error) return cb(error);
        var id = daoUtils.htoa(idHex);
        cb(null, id);
    });
};

DefaultDoug.prototype.actionsContractFromIndex = function (index, cb) {
    this._contract.actionsContractFromIndex(index, function(error, ret){
        if(error) return cb(error);
        var idHex = ret[0];
        var addr = ret[1];
        var code = ret[2].toNumber();

        var id = daoUtils.htoa(idHex);
        cb(null, id, addr, code);
    });
};

DefaultDoug.prototype.numActionsContracts = function (cb) {
    this._contract.numActionsContracts(cb);
};

DefaultDoug.prototype.setDestroyRemovedActions = function (destroyRemovedActions, cb) {
    var that = this;
    this._contract.setDestroyRemovedActions(destroyRemovedActions, {gas: this._gas}, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('SetDestroyRemovedActions', txHash, cb);
    });
};

DefaultDoug.prototype.destroyRemovedActions = function (cb) {
    this._contract.destroyRemovedActions(cb);
};

DefaultDoug.prototype.actionsContracts = function(cb){

    var that = this;

    this.numActionsContracts(function(error, num){
        if (error) return cb(error);
        var size = num.toNumber();
        var contracts = [];
        var i = 0;
        async.whilst(
            function () {
                return i < size;
            },
            function (cb) {
                that.actionsContractFromIndex(i, function(error, id, addr, code){
                    if (code === 0) {
                        contracts.push({identifier: id, address: addr});
                    }
                    i++;
                    cb(error);
                });
            },
            function (err) {
                cb(err, contracts);
            }
        );

    });

};

// Database-contracts

DefaultDoug.prototype.addDatabaseContract = function (identifier, address, cb) {
    var that = this;
    var idHex = daoUtils.atoh(identifier);
    this._contract.addDatabaseContract(idHex, address, {gas: this._gas}, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('AddDatabaseContract', txHash, cb);
    });
};

DefaultDoug.prototype.removeDatabaseContract = function (identifier, cb) {
    var that = this;
    var idHex = daoUtils.atoh(identifier);
    this._contract.removeDatabaseContract(idHex, {gas: this._gas}, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('RemoveDatabaseContract', txHash, cb);
    });
};

DefaultDoug.prototype.databaseContractAddress = function (identifier, cb) {
    var idHex = daoUtils.atoh(identifier);
    this._contract.databaseContractAddress(idHex, cb);
};

DefaultDoug.prototype.databaseContractId = function (address, cb) {
    this._contract.databaseContractId(address, function(error, idHex){
        if(error) return cb(error);
        var id = daoUtils.htoa(idHex);
        cb(null, id);
    });
};

DefaultDoug.prototype.databaseContractFromIndex = function (index, cb) {
    this._contract.databaseContractFromIndex(index, function(error, ret){
        if(error) return cb(error);
        var idHex = ret[0];
        var addr = ret[1];
        var code = ret[2].toNumber();

        var id = daoUtils.htoa(idHex);
        cb(null, id, addr, code);
    });
};

DefaultDoug.prototype.numDatabaseContracts = function (cb) {
    this._contract.numDatabaseContracts(cb);
};

DefaultDoug.prototype.numDatabaseContracts = function (cb) {
    this._contract.numDatabaseContracts(cb);
};

DefaultDoug.prototype.setDestroyRemovedDatabases = function (destroyRemovedDatabases, cb) {
    var that = this;
    this._contract.setDestroyRemovedDatabases(destroyRemovedDatabases, {gas: this._gas}, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('SetDestroyRemovedDatabases', txHash, cb);
    });
};

DefaultDoug.prototype.destroyRemovedDatabases = function (cb) {
    this._contract.destroyRemovedDatabases(cb);
};

DefaultDoug.prototype.databaseContracts = function(cb){

    var that = this;

    this.numDatabaseContracts(function(error, num){
        if (error) return cb(error);
        var size = num.toNumber();
        var contracts = [];
        var i = 0;
        async.whilst(
            function () {
                return i < size;
            },
            function (cb) {
                that.databaseContractFromIndex(i, function(error, id, addr, code){
                    if (code === 0) {
                        contracts.push({identifier: id, address: addr});
                    }
                    i++;
                    cb(error);
                });
            },
            function (err) {
                cb(err, contracts);
            }
        );

    });

};

// Doug

DefaultDoug.prototype.setPermission = function (permissionAddress, cb) {
    var that = this;
    this._contract.setPermission(permissionAddress, {gas: this._gas}, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('SetPermission', txHash, cb);
    });
};

DefaultDoug.prototype.permissionAddress = function (cb) {
    this._contract.permissionAddress(cb);
};

DefaultDoug.prototype.destroy = function (fundReceiver, cb) {
    var that = this;
    this._contract.destroy(fundReceiver, {gas: this._gas}, function(error, txHash){
        if(error) return cb(error);
        that.waitForDestroyed(txHash, cb);
    });
};

module.exports = DefaultDoug;