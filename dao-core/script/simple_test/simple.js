var util = require('util');

var ContractService = require('../../../script/contract_service');

function Simple(web3, contract, gas) {
    ContractService.call(this, web3, contract, gas);
}

util.inherits(Simple, ContractService);

Simple.prototype.addData = function (data, cb) {
    var that = this;
    this._contract.addData(data, {gas: this._gas}, function (error, txHash) {
        if (error) return cb(error);
        that.waitFor('AddData', txHash, cb);
    });
};

module.exports = Simple;