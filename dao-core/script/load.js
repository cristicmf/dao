var daoUtils = require('../../script/dao_utils');
var path = require('path');

var Doug = require('./doug');
var Permission = require('./permission');

function load(rootAddress, contractsFile) {
    var web3 = daoUtils.web3(rootAddress);
    var contractsFolder = path.join(__dirname, "../build/release");
    if (!contractsFile)
        contractsFile = path.join(__dirname, "bin", "contracts.json");
    var contracts = daoUtils.loadContracts(web3, contractsFile, contractsFolder);
    var services = {};
    var gas = daoUtils.defaultGas();
    services.perm = new Permission(web3, contracts.perm, gas);
    services.doug = new Doug(web3, contracts.doug, gas);
    return services;
}

module.exports = load;