/**
 * @file dao_core.js
 * @fileOverview dao-core script.
 * @author Andreas Olofsson (androlo1980@gmail.com)
 * @module dao_core
 */
"use strict";

var daoUtils = require('../../script/dao_utils');
var path = require('path');
var async = require('async');

var Doug = require('./doug');
var Permission = require('./permission');

/**
 * Deploy the dao-core contracts onto a running Ethereum chain:
 *
 * - Deploy a 'DefaultPermission' contract as 'perm', using the address in the deployer as root.
 * - Deploy a 'DefaultDoug' contract as 'doug', and set it to use the newly deployed permissions contract.
 *
 * The callback passes a reference to the deployer back, as well as a struct containing mappings
 * between the contracts and their services.
 *
 * {
 *     perm: permissionService,
 *     doug: dougService
 * }
 *
 * @param {Object} dep - The Deployer.
 * @param {Function} callback - function(error, dep, services)
 *
 * @alias module:dao_core.deploy
 */
function deploy(dep, callback) {

    var perm;
    var doug;

    // These are run in order.
    var steps = [
        deployPermission,
        testRootSet,
        deployDoug,
        testPermSet
    ];

    // Run

    async.series(steps, function (err) {
        if (err) return callback(err);
        console.log("All contracts deployed!");
        callback(null, dep, {
            perm: perm,
            doug: doug
        });
    });

    // The functions.

    function deployPermission(cb) {
        dep.deploy("perm", "DefaultPermission", [dep.address()], function (err, contract) {
            if (err) throw err;
            perm = new Permission(dep.web3(), contract, dep.gas());
            cb();
        })
    }

    // Basic check.
    function testRootSet(cb) {
        perm.root(function(err, addr){
            if (addr !== dep.address()) {
                return cb(new Error("Root address in permission is wrong: " + addr));
            }
            console.log("Root permission properly set.");
            cb();
        });
    }

    function deployDoug(cb) {
        var permAddr = perm.address();
        dep.deploy("doug", "DefaultDoug", [permAddr, false, false], function (err, contract) {
            if (err) throw err;
            doug = new Doug(dep.web3(), contract, dep.gas());
            cb();
        })
    }

    // Basic check.
    function testPermSet(cb) {
        doug.permissionAddress(function (error, dpAddr) {
            var pAddr = perm.address();
            if (dpAddr !== pAddr) {
                return cb(new Error("Permission address in doug is wrong: " + dpAddr));
            }
            console.log("Doug permission contract properly set.");
            cb();
        });
    }

}

/**
 * Load the dao-core contracts from a 'contracts.json' file.
 * The function returns a mapping between the contracts and the services.
 *
 * {
 *     perm: permissionService,
 *     doug: dougService
 * }
 *
 * @param {Object|string} rootAddressOrWeb3 - The address used when making calls to the chain. Can also be a web3 object.
 * @param {string} contractsFile - The path to the 'contracts.json' file.
 * @returns {{}} Mapping between contract names and services.
 *
 * @alias module:dao_core.load
 */
function load(rootAddressOrWeb3, contractsFile) {
    var web3;
    if (typeof(rootAddressOrWeb3) === 'string')
        web3 = daoUtils.web3(rootAddressOrWeb3);
    else
        web3 = rootAddressOrWeb3;
    if (!contractsFile)
        contractsFile = path.join(__dirname, "bin", "contracts.json");
    var contracts = daoUtils.loadContracts(web3, contractsFile);
    var services = {};
    var gas = daoUtils.defaultGas();
    services.perm = new Permission(web3, contracts.perm.contract, gas);
    services.doug = new Doug(web3, contracts.doug.contract, gas);
    return services;
}

exports.deploy = deploy;
exports.load = load;

/**
 *
 * @type {module:dao_core/doug~Doug}
 */
exports.Doug = Doug;

/**
 *
 * @type {module:dao_core/permission~Permission}
 */
exports.Permission = Permission;