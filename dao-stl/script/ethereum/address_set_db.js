var async = require('async');

function AddressSetDb(contract, gas) {
    this.eth = contract._eth;
    this.contract = contract;
    this.gas = gas;
}

AddressSetDb.prototype.addAddress = function (address, cb) {
    var that = this;
    this.contract.removeAddress(address, {gas: this.gas}, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('AddAddress', txHash, function(error, data){
            if(error) return cb(error);
            cb(null, args.added);
        })
    });
};

AddressSetDb.prototype.removeAddress = function (address, cb) {
    var that = this;
    this.contract.removeAddress(address, {gas: this.gas}, function(error, txHash){
        if(error) return cb(error);
        that.waitFor('RemoveAddress', txHash, function(error, data){
            if(error) return cb(error);
            cb(null, args.removed);
        })
    });
};

AddressSetDb.prototype.hasAddress = function (address, cb) {
    this.contract.hasAddress(address, cb);
};

AddressSetDb.prototype.addressFromIndex = function (index, cb) {
    this.contract.addressFromIndex(index, cb);
};

AddressSetDb.prototype.numAddresses = function (cb) {
    this.contract.numAddresses(cb);
};

AddressSetDb.prototype.values = function(cb){

    var that = this;

    this.contract.numAddresses(function(error, num){
        if (error) return cb(error);
        var size = num.toNumber();
        var addresses = [];
        var i = 0;
        async.whilst(
            function () {
                return i < size;
            },
            function (cb) {
                that.contract.addressFromIndex(i, function(error, address){
                    addresses.push(address);
                    i++;
                    cb(error);
                });
            },
            function (err) {
                cb(err, addresses);
            }
        );

    });

};

AddressSetDb.prototype.waitFor = function(eventName, hash, cb) {
    var event;
    try {
        event = this.contract['']();
    } catch (error) {
        return cb(error);
    }

    event.watch(function(error, data){
        if(hash === data.transactionHash) {
            if (timeout) clearTimeout(timeout);
            event.stopWatching();
            cb(null, data.args);

        }
    });

    var timeout = setTimeout(function(){event.stopWatching();} , 120000);
};

module.exports = AddressSetDb;