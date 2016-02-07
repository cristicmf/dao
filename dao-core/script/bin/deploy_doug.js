var path = require('path');
var dir = path.join(__dirname, "../../build/release");

var Deployer = require('../../../script/deployer.js');

var deployDoug = require('../deploy');

var dep = new Deployer(dir);

deployDoug(dep, function (err, dep) {
    if (err) throw err;
    dep.writeContracts(path.join(__dirname, "contracts.json"));
    console.log("Done.");
});