/**
 * @file dao_users.js
 * @fileOverview dao-users script.
 * @author Andreas Olofsson (androlo1980@gmail.com)
 * @module dao_users
 */
"use strict";

var daoUtils = require('../../script/dao_utils');
var path = require('path');
var async = require('async');

var UserDatabase = require('./user_database');
var UserRegistry = require('./user_registry');

/**
 * Deploy the dao-users contracts onto a running Ethereum chain:
 *
 * - Deploy a 'DefaultUserDatabase' contract as 'userDb'
 * - Deploy an 'AbstractUserRegistry' contract as 'userReg', using the address in the deployer as admin, and setting
 *      the database to 'userDb'. The actual implementation depends on the 'administered' flag.
 *
 * The callback passes a reference to the deployer back, as well as a struct containing mappings
 * between the contracts and their services.
 *
 * {
 *     userDb: userDbService,
 *     userReg: userRegistryService
 * }
 *
 * @param {Object} dep - The Deployer.
 * @param {boolean} administered - Whether to deploy an administered user registry, or one where users can register themselves.
 * @param {Function} callback - function(error, dep, services)
 *
 * @alias module:dao_users.deploy
 */
function deploy(dep, administered, callback) {

    var userDb;
    var userReg;

    // These are run in order.
    var steps = [
        deployDb,
        deployReg,
        testDbSet
    ];

    // Run

    async.series(steps, function (err) {
        if (err) return callback(err);
        console.log("All contracts deployed!");
        callback(null, dep, {
            userDb: userDb,
            userReg: userReg
        });
    });

    // The functions.

    function deployDb(cb) {
        dep.deploy("userDb", "DefaultUserDatabase", function (err, contract) {
            if (err) throw err;
            userDb = new UserDatabase(dep.web3(), contract, dep.gas());
            cb();
        })
    }

    function deployReg(cb) {
        var type = administered ? "AdminRegUserRegistry" : "SelfRegUserRegistry";
        console.log(type);
        console.log(userDb.address());
        var dbAddr = userDb.address();
        console.log(dep.address());
        dep.deploy("userReg", type, [dbAddr, dep.address()], function (err, contract) {
            if (err) throw err;
            userReg = new UserRegistry(dep.web3(), contract, dep.gas());
            cb();
        })
    }

    // Basic check.
    function testDbSet(cb) {
        userReg.userDatabase(function (error, dudbAddr) {
            var udbAddr = userDb.address();
            if (dudbAddr !== udbAddr) {
                return cb(new Error("User database address in registry is wrong: " + dudbAddr));
            }
            console.log("Database added to registry.");
            cb();
        });
    }

}

/**
 * Load the dao-users contracts from a 'contracts.json' file.
 * The function returns a mapping between the contracts and the services.
 *
 * {
 *     userDb: userDbService,
 *     userReg: userRegistryService
 * }
 *
 * @param {string} rootAddress - The address used when making calls to the chain.
 * @param {string} contractsFile - The path to the 'contracts.json' file.
 * @returns {{}} Mapping between contract names and services.
 *
 * @alias module:dao_users.load
 */
function load(rootAddress, contractsFile) {
    var web3 = daoUtils.web3(rootAddress);
    var contractsFolder = path.join(__dirname, "../build/release");
    if (!contractsFile)
        contractsFile = path.join(__dirname, "bin", "contracts.json");
    var contracts = daoUtils.loadContracts(web3, contractsFile, contractsFolder);
    var services = {};
    var gas = daoUtils.defaultGas();
    services.userDb = new UserDatabase(web3, contracts.userDb.contract, gas);
    services.userReg = new UserRegistry(web3, contracts.doug.contract, gas);
    return services;
}

exports.deploy = deploy;
exports.load = load;

/**
 *
 * @type {module:dao_users/user_database~UserDatabase}
 */
exports.UserDatabase = UserDatabase;

/**
 *
 * @type {module:dao_users/user_registry~UserRegistry}
 */
exports.UserRegistry = UserRegistry;