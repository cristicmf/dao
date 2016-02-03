var fs = require('fs-extra');
var path = require('path');
var async = require('async');
var errors = require('../../../script/errors');

var Deployer = require('../../../script/deployer');

var DefaultDoug = require('./default_doug');
var DefaultPermission = require('./default_permission');

// *************************************************************

function deploy() {

    var dir = path.join(__dirname, "../../contracts/build/test");
    var dep = new Deployer(dir, "http://localhost:8545");

    var settable;

    var perm;
    var doug;

    async.series([
        deployPermission,
        deployDoug,
        testRootSet,
        testPermSet,
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
    ], function (err) {
        if (err) throw err;
        console.log("Done!");
    });

    function deployPermission(cb) {
        dep.deploy("DefaultPermission", [dep.address()], function (err, contract) {
            if (err) throw err;
            perm = new DefaultPermission(dep.web3(), contract, dep.gas());
            cb();
        })
    }

    function deployDoug(cb) {
        var permAddr = perm.address();
        dep.deploy("DefaultDoug", [permAddr, false, false], function (err, contract) {
            if (err) return cb(err);
            doug = new DefaultDoug(dep.web3(), contract, dep.gas());
            cb();
        })
    }

    // Basic check.
    function testRootSet(cb) {
        perm.root(function (error, addr){
            if (error) return cb(error);
            if (addr !== dep.address()) {
                return cb(new Error("Root address in permission is wrong: " + pRoot));
            }
            console.log("Root permission properly set.");
            cb();
        });
    }

    // Basic check.
    function testPermSet(cb) {
        doug.permissionAddress(function (error, addr) {
            if (error) return cb(error);
            var pAddr = perm.address();
            if (addr !== pAddr) {
                return cb(new Error("Permission address in doug is wrong: " + addr));
            }
            console.log("Doug permission contract properly set.");
            cb();
        });
    }

    function deploySettable(cb) {
        dep.deploy("DefaultDougSettable", [], function (err, contract) {
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

deploy();