var async = require('async');
var util = require('util');

var ContractService = require('../../../script/contract_service');
var daoUtils = require('../../../script/dao_utils');

function DefaultPermission(web3, contract, gas) {
    ContractService.call(this, web3, contract, gas);
}

util.inherits(DefaultPermission, ContractService);

DefaultPermission.prototype.setRoot = function (newRoot, cb) {
    var that = this;
    this._contract.setPermission(newRoot, {gas: this._gas}, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('SetRoot', txHash, cb);
    });
};

DefaultPermission.prototype.root = function (cb) {
    this._contract.root(cb);
};

DefaultPermission.prototype.rootData = function (cb) {
    this._contract.rootData(function(error, ret){
        if (error) return cb(error);
        var addr = ret[0];
        var time = daoUtils.bnToDate(ret[1]);
        cb(null, addr, time);
    });
};

DefaultPermission.prototype.addOwner = function (address, cb) {
    var that = this;
    this._contract.addOwner(address, {gas: this._gas}, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('AddOwner', txHash, cb);
    });
};

DefaultPermission.prototype.removeOwner = function (address, cb) {
    var that = this;
    this._contract.removeOwner(address, {gas: this._gas}, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('RemoveOwner', txHash, cb);
    });
};

DefaultPermission.prototype.ownerTimestamp = function (cb) {
    this._contract.ownerTimestamp(function(error, ret){
        if (error) return cb(error);
        var time = daoUtils.bnToDate(ret[0]);
        var code = ret[1].toNumber();
        cb(null, time, code);
    });
};

DefaultPermission.prototype.ownerFromIndex = function (cb) {
    this._contract.ownerFromIndex(function(error, ret){
        if (error) return cb(error);
        var addr = ret[0];
        var time = daoUtils.bnToDate(ret[1]);
        var code = ret[2].toNumber();
        cb(null, addr, time, code);
    });
};

DefaultPermission.prototype.numOwners = function (cb) {
    this._contract.numOwners(cb);
};

DefaultPermission.prototype.hasPermission = function (address, cb) {
    this._contract.hasPermission(address, cb);
};

DefaultPermission.prototype.owners = function(cb){

    var that = this;

    this.numOwners(function(error, num){
        if (error) return cb(error);
        var size = num.toNumber();
        var contracts = [];
        var i = 0;
        async.whilst(
            function () {
                return i < size;
            },
            function (cb) {
                that.ownerFromIndex(i, function(error, addr, time, code){
                    if (code === 0) {
                        contracts.push({address: addr, timestamp: time});
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

DefaultPermission.prototype.destroy = function (fundReceiver, cb) {
    var that = this;
    this._contract.destroy(fundReceiver, {gas: this._gas}, function(error, txHash){
        if(error) return cb(error);
        that.waitForDestroyed(txHash, cb);
    });
};

module.exports = DefaultPermission;