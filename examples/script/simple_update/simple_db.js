var util = require('util');

var ContractService = require('../../../script/contract_service');

function SimpleDb(web3, contract, gas) {
    ContractService.call(this, web3, contract, gas);
}

util.inherits(SimpleDb, ContractService);

SimpleDb.prototype.data = function (cb) {
    this._contract.data(function(err, data) {
        if (err) return cb(err);
        cb(null, data.toNumber());
    });
};

module.exports = SimpleDb;