var daoUtils = require('../../../script/dao_utils');
var path = require('path');

var Doug = require('../../../dao-core/script/doug');
var SimpleDb = require('./simple_db');
var Simple = require('./simple');

function load(rootAddressOrWeb3, contractsFile) {
    var web3;
    if (typeof(rootAddressOrWeb3) === 'string')
        web3 = daoUtils.web3(rootAddressOrWeb3);
    else
        web3 = rootAddressOrWeb3;
    if (!contractsFile)
        contractsFile = path.join(__dirname, "contracts.json");
    var contracts = daoUtils.loadContracts(web3, contractsFile);
    var services = {};
    var gas = daoUtils.defaultGas();

    services.doug = new Doug(web3, contracts.doug.contract, gas);
    services.simpleDb = new SimpleDb(web3, contracts.simpleDb.contract, gas);
    services.simple = new Simple(web3, contracts.simple.contract, gas);

    return services;
}

module.exports = load;