var path = require('path');
var dir = path.join(__dirname, "../../build/release");

var Deployer = require('../../../script/deployer.js');

var deployUsers = require('../dao_users').deploy;

var dep = new Deployer(dir);

deployUsers(dep, true, function (err, dep) {
    if (err) throw err;
    dep.writeContracts(path.join(__dirname, "contracts.json"));
    console.log("Done.");
});