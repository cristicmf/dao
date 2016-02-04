var async = require('async');
var util = require('util');

var ContractService = require('../../../script/contract_service');

function AddressSetDb(web3, contract, gas) {
    ContractService.call(this, web3, contract, gas);
}

util.inherits(AddressSetDb, ContractService);

AddressSetDb.prototype.addAddress = function (address, cb) {
    var that = this;
    this._contract.addAddress(address, {gas: this._gas}, function(error, txHash){
        if(error) return cb(error);
        that.waitForArgs('AddAddress', txHash, cb);
    });
};

AddressSetDb.prototype.removeAddress = function (address, cb) {
    var that = this;
    this._contract.removeAddress(address, {gas: this._gas}, function(error, txHash){
        if(error) return cb(error);
        that.waitForArgs('RemoveAddress', txHash, cb);
    });
};

AddressSetDb.prototype.hasAddress = function (address, cb) {
    this._contract.hasAddress(address, cb);
};

AddressSetDb.prototype.addressFromIndex = function (index, cb) {
    this._contract.addressFromIndex(index, function(err, ret) {
        if (err) return cb(err);
        var fmt = afiFormat(ret);
        cb(null, fmt.address, fmt.exists);
    })
};

AddressSetDb.prototype.numAddresses = function (cb) {
    this._contract.numAddresses(cb);
};

AddressSetDb.prototype.values = function(cb){

    var that = this;

    var block = this._web3.eth.blockNumber;

    this._contract.numAddresses(block, function(error, num){
        if (error) return cb(error);
        var size = num.toNumber();
        var addresses = [];
        var i = 0;
        async.whilst(
            function () {
                return i < size;
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
    var fmt = {};
    fmt.address = ret[1];
    fmt.exists = ret[2];
    return fmt;
}

module.exports = AddressSetDb;