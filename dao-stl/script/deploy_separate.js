var fs = require('fs-extra');
var path = require('path');
var async = require('async');

var AddressSetDb = require('./address_set_db');

// *****************

function deploy(dep, callback) {

    var TEST_ADDRESS = "0x1234123412341234123412341234123412341234";

    var asdb;

    console.log("Starting to deploy.");

    // These are run in order.
    var steps = [
        deployAddressSet,
        deployAddressSetDb,
        testAddAddresses,
        testHasAddress,
        testValues,
        testRemoveAddress,
        testValues
    ];

    // Run

    async.series(steps, function (err) {
        if (err) return callback(err);
        callback(null, dep, {
            asdb: asdb
        })
    });

    // The functions.

    function deployAddressSet(cb) {
        dep.deployLibrary("AddressSet", function (err) {
            if (err) throw err;
            cb();
        })
    }

    function deployAddressSetDb(cb) {
        dep.deploy("asdb", "AddressSetDb", function (err, contract) {
            if (err) throw err;
            asdb = new AddressSetDb(dep.web3(), contract, dep.gas());
            cb();
        })
    }

    // Add an address.
    function testAddAddresses(cb) {
        console.log("Inserting: " + TEST_ADDRESS);
        asdb.addAddress(TEST_ADDRESS, function (error, args) {
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
        asdb.values(null, function (error, values) {
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

module.exports = deploy;