var daoUtils = require('../../../script/dao_utils');
var path = require('path');

var Doug = require('../../../dao-core/script/doug');
var SimpleDb = require('./simple_db');
var Simple = require('./simple');

function load(rootAddress, contractsFile) {
    var web3 = daoUtils.web3(rootAddress);
    var contractsFolder = path.join(__dirname, "../../../dao-core/build/test");
    if (!contractsFile)
        contractsFile = path.join(__dirname, "contracts.json");
    var contracts = daoUtils.loadContracts(web3, contractsFile, contractsFolder);
    var services = {};
    var gas = daoUtils.defaultGas();

    services.doug = new Doug(web3, contracts.doug, gas);
    services.simpleDb = new SimpleDb(web3, contracts.simpleDb, gas);
    services.simple = new Simple(web3, contracts.simple, gas);

    return services;
}

module.exports = load;