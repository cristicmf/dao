var fs = require('fs-extra');
var path = require('path');
var async = require('async');

var Deployer = require('../../../script/deployer.js');
var AddressSetDb = require('./admin_reg_user_registry');

// *****************

function deploy(callback) {

    var TEST_ADDRESS = "0x1234123412341234123412341234123412341234";
    var TEST_ADDRESS_2 = "0x2234123412341234123412341234123412341234";
    var TEST_ADDRESS_3 = "0x3234123412341234123412341234123412341234";

    var dir = path.join(__dirname, "../../contracts/build/test");
    var dep = new Deployer(dir, "http://localhost:8545");

    var asdb;

    console.log("Starting to deploy.");

    async.series([deployAddressSetDb, testAddAddresses, testHasAddress, testValues, testRemoveAddress], function (err) {
        if (err) throw err;
        console.log("All contracts deployed!");
    });

    function deployAddressSetDb(cb) {
        dep.deploy("AddressSetDb", [], function (err, contract) {
            if (err) throw err;
            asdb = new AddressSetDb(contract, dep.gas());
            cb();
        })
    }

    // Add an address.
    function testAddAddresses(cb) {
        async.parallel([
            function (cb2) {
                asdb.addAddress(TEST_ADDRESS, cb2)
            },
            function (cb2) {
                asdb.addAddress(TEST_ADDRESS_2, cb2)
            },
            function (cb2) {
                asdb.addAddress(TEST_ADDRESS_3, cb2)
            }
        ], function (error) {
            cb(error);
        });
    }

    function testHasAddress(cb) {
        async.parallel([
            function (cb2) {
                console.log("Inserting: " + TEST_ADDRESS);
                asdb.hasAddress(TEST_ADDRESS, cb2)
            },
            function (cb2) {
                console.log("Inserting: " + TEST_ADDRESS_2);
                asdb.hasAddress(TEST_ADDRESS_2, cb2)
            },
            function (cb2) {
                console.log("Inserting: " + TEST_ADDRESS_3);
                asdb.hasAddress(TEST_ADDRESS_3, cb2)
            }
        ], function (error, results) {
            if (error) return cb(error);
            if(results[0] && results[1] && results[2])
                console.log("Set has all addresses");
            else
                console.log("Addresses are missing from set.");
            cb();
        });
    }

    function testValues(cb) {
        asdb.values(function (error, ret) {
            console.log("List of values");
            var values = ret.map(function(arr){return arr[0]});
            console.log(values);
            cb(error);
        });
    }

    // Add an address.
    function testRemoveAddress(cb) {
        asdb.removeAddress(TEST_ADDRESS, function (error, removed) {
            if (removed)
                console.log(TEST_ADDRESS + " was successfully removed.");
            else
                console.log("Failed to remove " + TEST_ADDRESS);
            cb(error);
        });
    }


}

deploy(function () {
});