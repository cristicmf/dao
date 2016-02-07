var fs = require('fs-extra');
var path = require('path');
var async = require('async');
var errors = require('../../../script/errors');

var deployDoug = require('../deploy');

var Deployer = require('../../../script/deployer');

var dir = path.join(__dirname, "../../build/test");
var dep = new Deployer(dir);

// Call deploy doug and get the permission and doug services.
deployDoug(dep, function (error, dep, services) {
    if (error) throw error;
    // Run the tests.
    test(services, function(err){
        if (err) throw err;
        console.log("Done.");
    });
});

// *************************************************************

function test(services, callback) {

    var settable;

    var perm = services.perm;
    var doug = services.doug;

    // These are run in order.

    var steps = [
        deploySettable,
        testAddActionsContract,
        testActionsContractAddress,
        testActionsContractId,
        testActionsContracts,
        testRemoveActionsContract,
        testActionsContracts,
        testAddDatabaseContract,
        testDatabaseContractAddress,
        testDatabaseContractId,
        testDatabaseContracts,
        testRemoveDatabaseContract,
        testDatabaseContracts,
        destroyDoug,
        destroyPermission,
        checkDougGone,
        checkPermissionGone
    ];

    // Run

    async.series(steps, callback);

    // The functions.

    function deploySettable(cb) {
        dep.deploy("settable", "DefaultDougSettable", function (err, contract) {
            if (err) return cb(err);
            settable = contract;
            cb();
        });
    }

    function testAddActionsContract(cb) {
        console.log("Adding actions contract: " + settable.address);
        doug.addActionsContract("test", settable.address, function (error, code) {
            if (error) return cb(error);
            if (code !== 0) {
                return cb(new Error("Add returned error: " + errors.error(code)));
            }
            console.log("Contract added.");
            cb();
        });
    }

    function testActionsContractAddress(cb) {
        console.log("Getting address from id");
        doug.actionsContractAddress("test", function (error, address) {
            if (error) return cb(error);
            if (address != settable.address) {
                return cb(new Error("Wrong address: " + address));
            }
            console.log("Contract address: " + address);
            cb();
        });
    }

    function testActionsContractId(cb) {
        console.log("Getting id from address");
        doug.actionsContractId(settable.address, function (error, id) {
            if (error) return cb(error);
            if (id !== "test") {
                return cb(new Error("Wrong id: " + id));
            }
            console.log("Contract id: " + id);
            cb();
        });
    }

    function testActionsContracts(cb) {
        console.log("Getting list of actions-contracts.");
        doug.actionsContracts(function (error, list) {
            if (error) return cb(error);
            console.log("Contracts:");
            console.log(list);
            cb();
        });
    }

    function testRemoveActionsContract(cb) {
        console.log("Removing actions contract: test");
        doug.removeActionsContract("test", function (error, code) {
            if (error) return cb(error);
            if (code !== 0) {
                return cb(new Error("Remove returned error: " + errors.error(code)));
            }
            console.log("Contract removed.");
            cb();
        });
    }

    function testAddDatabaseContract(cb) {
        console.log("Adding database contract: " + settable.address);
        doug.addDatabaseContract("test", settable.address, function (error, code) {
            if (error) return cb(error);
            if (code !== 0) {
                return cb(new Error("Add returned error: " + errors.error(code)));
            }
            console.log("Contract added.");
            cb();
        });
    }

    function testDatabaseContractAddress(cb) {
        console.log("Getting address from id.");
        doug.databaseContractAddress("test", function (error, address) {
            if (error) return cb(error);
            if (address != settable.address) {
                return cb(new Error("Wrong address: " + address));
            }
            console.log("Contract address: " + address);
            cb();
        });
    }

    function testDatabaseContractId(cb) {
        console.log("Getting id from address");
        doug.databaseContractId(settable.address, function (error, id) {
            if (error) return cb(error);
            if (id !== "test") {
                return cb(new Error("Wrong id: " + id));
            }
            console.log("Contract id: " + id);
            cb();
        });
    }

    function testDatabaseContracts(cb) {
        console.log("Getting list of database-contracts.");
        doug.databaseContracts(function (error, list) {
            if (error) return cb(error);
            console.log("Contracts:");
            console.log(list);
            cb();
        });
    }

    function testRemoveDatabaseContract(cb) {
        console.log("Removing database contract: test");
        doug.removeDatabaseContract("test", function (error, code) {
            if (error) return cb(error);
            if (code !== 0) {
                return cb(new Error("Remove returned error: " + errors.error(code)));
            }
            console.log("Contract removed.");
            cb();
        });
    }

    function destroyDoug(cb) {
        console.log("Destroying doug.");
        doug.destroy(dep.address(), function (error, code) {
            if (error) return cb(error);
            if (code !== 0) {
                return cb(new Error("Destroy returned error: " + errors.error(code)));
            }
            console.log("Contract removed.");
            cb();
        });
    }

    function destroyPermission(cb) {
        console.log("Destroying permissions.");
        perm.destroy(dep.address(), function (error, code) {
            if (error) return cb(error);
            if (code !== 0) {
                return cb(new Error("Destroy returned error: " + errors.error(code)));
            }
            console.log("Contract removed.");
            cb();
        });
    }

    function checkDougGone(cb) {
        dep.web3().eth.getCode(doug.address(), function(error, code){
            if(error) return cb(error);
            if (code !== "0x") {
                return cb(new Error("Doug account still left"));
            }
            console.log("Doug account confirmed gone.");
            cb();
        });
    }

    function checkPermissionGone(cb) {
        dep.web3().eth.getCode(perm.address(), function(error, code){
            if(error) return cb(error);
            if (code !== "0x") {
                return cb(new Error("Permission account still left"));
            }
            console.log("Permission account confirmed gone.");
            cb();
        });
    }

}