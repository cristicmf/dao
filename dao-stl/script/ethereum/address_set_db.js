var async = require('async');

function AddressSetDb(contract, gas) {
    this.eth = contract._eth;
    this.contract = contract;
    this.gas = gas;
}

AddressSetDb.prototype.addAddress = function (address, cb) {

    var that = this;
    var hash;
    var event = that.contract.AddAddress();

    event.watch(function(error, data){
        if(hash && hash === data.transactionHash) {
            event.stopWatching();
            cb(null, data.args.had);
        }
    });

    this.contract.addAddress(address, {gas: this.gas}, function(error, txHash){
        hash = txHash;
        if(error) {
            event.stopWatching();
            return cb(error);
        }
    })
};

AddressSetDb.prototype.removeAddress = function (address, cb) {

    var that = this;
    var hash;
    var event = that.contract.RemoveAddress();

    event.watch(function(error, data){
        if(hash && hash === data.transactionHash) {
            event.stopWatching();
            cb(null, data.args.removed);
        }
    });

    this.contract.removeAddress(address, {gas: this.gas}, function(error, txHash){
        hash = txHash;
        if(error) {
            event.stopWatching();
            return cb(error);
        }
    })
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

module.exports = AddressSetDb;