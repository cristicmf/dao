var path = require('path');
var errors = require('../../../script/errors');
var load = require('./load');
var cFile = path.join(__dirname, "contracts.json");
var daoUtils = require('../../../script/dao_utils');

var addr = daoUtils.web3(null).eth.defaultAccount;

// Get all the current contracts.
var services = load(addr, cFile);
services.simple.addData(5, function(err, code){
    // If successful, write the contract data.
    if (err) throw err;
    if (code !== 0) {
        throw new Error("addData returned error: " + errors.error(code));
    }
    console.log("Data added.");
});