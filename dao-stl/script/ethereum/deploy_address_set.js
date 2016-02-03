var fs = require('fs-extra');
var path = require('path');
var async = require('async');

var Deployer = require('../../../script/deployer.js');
var AddressSetDb = require('./address_set_db');

// *****************

function deploy(callback) {

    var TEST_ADDRESS = "0x1234123412341234123412341234123412341234";

    var dir = path.join(__dirname, "../../contracts/build/test");
    var dep = new Deployer(dir, "http://localhost:8545");

    var asdb;

    console.log("Starting to deploy.");

    async.series([deployAddressSetDb, testAddAddresses, testHasAddress, testValues, testRemoveAddress, testValues], function (err) {
        if (err) throw err;
        console.log("All contracts deployed!");
    });

    function deployAddressSetDb(cb) {
        dep.deploy("AddressSetDb", [], function (err, contract) {
            if (err) throw err;
            asdb = new AddressSetDb(dep.web3(), contract, dep.gas());
            cb();
        })
    }

    // Add an address.
    function testAddAddresses(cb) {
        console.log("Inserting: " + TEST_ADDRESS);
        asdb.addAddress(TEST_ADDRESS, function(error, args){
            if (error) return cb(error);
            if (args.added)
                console.log("Address was added");
            else
                return cb(new Error("Address was not added."));
            cb();
        });
    }

    function testHasAddress(cb) {
        console.log("Checking address.");
        asdb.hasAddress(TEST_ADDRESS, function (error, has) {
            console.log(has);
            if (error) return cb(error);
            if (has)
                console.log("Set has address");
            else
                return cb(new Error("Address is missing from set."));
            cb();
        });
    }

    function testValues(cb) {
        asdb.values(function (error, values) {
            if (error) return cb(error);
            console.log("List of values");
            console.log(values);
            cb();
        });
    }

    // Add an address.
    function testRemoveAddress(cb) {
        asdb.removeAddress(TEST_ADDRESS, function (error, args) {
            if (args.removed)
                console.log(TEST_ADDRESS + " was successfully removed.");
            else
                console.log("Failed to remove " + TEST_ADDRESS);
            cb(error);
        });
    }
}

deploy(function () {
});