var async = require('async');
var path = require('path');
var solUnit = require('sol-unit');
var errors = require('../../../script/errors');
var Deployer = require('../../../script/deployer');
var Simple = require('./simple');

var loadDoug = require('./load');

var dir = path.join(__dirname, "../../build/test");
var cFile = path.join(__dirname, "contracts.json");

var dep = new Deployer(dir);

// Start by unit-testing all contracts we're about to deploy. If the tests fail, throw.
solUnit.runTests(['SimpleTwoTest'], dir, true, function (stats) {
    var failed = stats.total - stats.successful;
    var skipped = stats.numSkippedUnits;
    if (failed || skipped)
        throw new Error("Tests failed");

    // Get all the current contracts.
    var services = loadDoug(dep.address(), cFile);
    deploySimple(services, function(err, dep, stuff){
        // If successful, write the contract data.
        if (err) throw err;
        dep.writeContracts(cFile, true);
        console.log("Done.");
    });

});

function deploySimple(services, callback) {

    var doug = services.doug;
    var sdb = services.simpleDb;

    var st;

    // These are run in order.
    var steps = [
        deploySimpleTwo,
        removeSimpleOneFromDoug,
        addSimpleTwoToDoug,
        testSimpleTwoAdded
    ];

    // Run

    async.series(steps, function (err) {
        if (err) return callback(err);
        console.log("All contracts deployed!");
        services.simple = st;
        callback(null, dep, services);
    });

    // The functions.

    function deploySimpleTwo(cb) {
        dep.deploy("simple", "SimpleTwo", [sdb.address()], function (err, contract) {
            if (err) throw err;
            st = new Simple(dep.web3(), contract, dep.gas());
            cb();
        })
    }

    function removeSimpleOneFromDoug(cb) {
        doug.removeActionsContract("simple", function (error, code) {
            if (error) return cb(error);
            if (code !== 0) {
                return cb(new Error("removeActionsContract returned error: " + errors.error(code)));
            }
            console.log("simpleOne removed from doug.");
            cb();
        });
    }

    function addSimpleTwoToDoug(cb) {
        doug.addActionsContract("simple", st.address(), function (error, code) {
            if (error) return cb(error);
            if (code !== 0) {
                return cb(new Error("addActionsContract returned error: " + errors.error(code)));
            }
            console.log("simpleTwo added to doug.");
            cb();
        });
    }

    // Basic check.
    function testSimpleTwoAdded(cb) {
        doug.actionsContractAddress("simple", function(err, addr){
            if (addr !== st.address()) {
                return cb(new Error("simple cannot be found in Doug. Address: " + addr));
            }
            console.log("simple properly added.");
            cb();
        });
    }
}