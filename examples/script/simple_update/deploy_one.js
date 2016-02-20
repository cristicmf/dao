var async = require('async');
var path = require('path');
var solUnit = require('sol-unit');
var errors = require('../../../script/errors');
var Deployer = require('../../../script/deployer');
var SimpleDb = require('./simple_db');
var Simple = require('./simple');

var deployDoug = require('../../../dao-core/script/dao_core').deploy;

var dir = path.join(__dirname, "../../../dao-core/build/test");
var dep = new Deployer(dir);

// Start by unit-testing all contracts we're about to deploy. If the tests fail, throw.
solUnit.runTests([
    'DefaultPermissionTest',
    'DefaultDougTest',
    'DefaultDougEnabledTest',
    'DefaultDougActionsTest',
    'DefaultDougDatabaseTest',
    'DefaultSimpleDbTest',
    'SimpleOneTest'
], dir, true, function (stats) {
    var failed = stats.total - stats.successful;
    var skipped = stats.numSkippedUnits;
    if (failed || skipped)
        throw new Error("Tests failed");

    // Call deploy doug and get the permission and doug services.
    deployDoug(dep, function (error, dep, services) {
        if (error) throw error;
        // Now we deploy the SimpleDb and SimpleOne contracts.
        deploySimple(services, function(err, dep, stuff){
            // If successful, write the contract data.
            if (err) throw err;
            dep.writeContracts(path.join(__dirname, "contracts.json"));
            console.log("Done.");
        });
    });
});



function deploySimple(dougServices, callback) {

    var doug = dougServices.doug;

    var sdb, so;

    // These are run in order.
    var steps = [
        deploySimpleDb,
        addSimpleDbToDoug,
        testSimpleDbAdded,
        deploySimpleOne,
        addSimpleOneToDoug,
        testSimpleOneAdded
    ];

    // Run

    async.series(steps, function (err) {
        if (err) return callback(err);
        console.log("All contracts deployed!");
        callback(null, dep, {
            perm: dougServices.perm,
            doug: doug,
            simple: so,
            sdb: sdb
        });
    });

    // The functions.

    function deploySimpleDb(cb) {
        dep.deploy("simpleDb", "DefaultSimpleDb", ["simple"], function (err, contract) {
            if (err) throw err;
            sdb = new SimpleDb(dep.web3(), contract, dep.gas());
            cb();
        })
    }

    function addSimpleDbToDoug(cb) {
        doug.addDatabaseContract({id: "simpleDb", address: sdb.address()}, function (error, code) {
            if (error) return cb(error);
            if (code !== 0) {
                return cb(new Error("addDatabaseContract returned error: " + errors.error(code)));
            }
            console.log("simpleDb added to doug.");
            cb();
        });
    }

    // Basic check.
    function testSimpleDbAdded(cb) {
        doug.databaseContractAddress("simpleDb", function(err, addr){
            if (addr !== sdb.address()) {
                return cb(new Error("simpleDb cannot be found in Doug. Address: " + addr));
            }
            console.log("simpleDb properly added.");
            cb();
        });
    }

    function deploySimpleOne(cb) {
        dep.deploy("simple", "SimpleOne", [sdb.address()], function (err, contract) {
            if (err) throw err;
            so = new Simple(dep.web3(), contract, dep.gas());
            cb();
        })
    }

    function addSimpleOneToDoug(cb) {
        doug.addActionsContract({id: "simple", address: so.address()}, function (error, code) {
            if (error) return cb(error);
            if (code !== 0) {
                return cb(new Error("addActionsContract returned error: " + errors.error(code)));
            }
            console.log("simpleOne added to doug.");
            cb();
        });
    }

    // Basic check.
    function testSimpleOneAdded(cb) {
        doug.actionsContractAddress("simple", function(err, addr){
            if (addr !== so.address()) {
                return cb(new Error("simple cannot be found in Doug. Address: " + addr));
            }
            console.log("simple properly added.");
            cb();
        });
    }
}