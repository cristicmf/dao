/**
 * @file deployer.js
 * @fileOverview A utility for deploying contracts onto an Ethereum block-chain.
 * @author Andreas Olofsson (androlo1980@gmail.com)
 * @module deployer
 */
'use strict';

var async = require('async');
var fs = require('fs-extra');
var path = require('path');
var daoUtils = require('./dao_utils');

/**
 * Deployer is used to deploy contracts onto an ethereum block-chain. It deploys contracts,
 * keeps track of them, and can write an output file with the contract addresses. It accepts
 * a list of libraries if those are already deployed on the chain, otherwise it will automatically
 * find and link them automatically (provided the library .bin and .abi files of each library can
 * be found in the root folder).
 *
 * These are the available options:
 *
 * 'gas'        - An amount of gas to use when sending transactions. Defaults to 3 million.
 * 'address'    - The address to use as sender when deploying. If not set, it will look for the
 *                'DOUG_ROOT' environment variable, and lastly default to 'web3.eth.coinbase'.
 * 'ethURL'     - The URL to the Ethererum RPC-server. Defaults to 'http://localhost:8545'
 * 'libraries'  - A libraries json file. This is useful if the chain already has libraries on it.
 *
 * Deployed contracts are stored as a mapping:
 * 'contracts[name] = {abi: <object>, bytecode: <string>, contract: <object>}'
 * The 'abi' is a json ABI object, bytecode is a hex-string, and contract is a web3 contract.
 *
 * @param {string} [rootDir] - The directory where contract .bin and .abi files are stored.
 * @param {Object} [options] - The options.
 *
 * @constructor
 */
function Deployer(rootDir, options) {
    this._libs = {};
    this._contracts = {};
    if (typeof(rootDir) !== 'string')
        options = rootDir;
    else
        this._rootDir = rootDir;

    var opts = options || {};
    this._gas = opts.gas || daoUtils.defaultGas();
    var web3 = daoUtils.web3(opts.address, opts.ethURL);
    this._address = web3.eth.defaultAccount;

    this._web3 = web3;
    if (opts.libraries) {

        var lData = fs.readJsonSync(opts.libraries);

        for (var lib in lData.libraries) {
            if (lData.libraries.hasOwnProperty(lib)) {
                var libAddr = lData.libraries[lib];
                var code = web3.eth.getCode(libAddr);
                if (code === "0x") {
                    throw new Error("Library: '" + lib + "' at '" + libAddr + "' had no code in it");
                }
                this._libs[lib] = {address: libAddr, bytecode: code};
            }
        }
    }
}

/**
 * Deploy a contract. Will register the contract in the deployed contracts registry,
 * and automatically link with libraries if needed.
 *
 * @param {string} name - The name of the contract instance (user defined).
 * @param {string} type - The name of the contract type as it appears in the .sol file.
 * @param {Array} [params] - An array of the constructor params in order.
 * @param {Function} cb - Error-first callback: 'function(error, contract)', where contract is a web3 contract.
 */
Deployer.prototype.deploy = function (name, type, params, cb) {
    var callback;
    if (typeof(params) === 'function') {
        callback = params;
        params = [];
    } else {
        callback = cb;
    }
    var binPath = path.join(this._rootDir, type + ".bin");
    var abiPath = path.join(this._rootDir, type + ".abi");

    try {
        var bytecode = '0x' + fs.readFileSync(binPath).toString();
        var abi = fs.readJsonSync(abiPath);
        if (this._contracts[name]) {
            return callback(new Error('Duplicate name: ' + name));
        }
        this._contracts[name] = {type: type, bytecode: bytecode, abi: abi};
    } catch (err) {
        return callback(new Error("Contract: '" + type + "' missing binary (.bin) or abi (.abi) file in root dir."));
    }

    var that = this;
    // Deploy and link libraries before adding to contracts list.
    this._linkBytecode(bytecode, function (err, newBytecode) {
        if (err) return callback(err);
        var cObj = that._contracts[name];
        cObj.bytecode = newBytecode;
        console.log("Deploying: " + name);

        var cf = that._web3.eth.contract(cObj.abi);

        if (!params) {
            params = [];
        }

        var opts = {data: newBytecode, gas: that._gas};
        params.push(opts);
        params.push(function (err, ctr) {
            if (err) {
                callback(err);
            } else if (ctr.address) {
                cObj.contract = ctr;
                console.log("Contract '" + name + "' {" + type + "} deployed at: " + ctr.address);
                callback(null, ctr);
            }
        });
        cf.new.apply(cf, params);
    });

};

/**
 * Deploy a library. Will register the contract in the deployed libraries registry,
 * and automatically link with library dependencies if needed.
 *
 * @param {string} type - The name of the contract type as it appears in the .sol file.
 * @param {Function} cb - function(error)
 */
Deployer.prototype.deployLibrary = function (type, cb) {
    var callback = cb;

    var binPath = path.join(this._rootDir, type + ".bin");
    var abiPath = path.join(this._rootDir, type + ".abi");

    var libBytecode;
    var lib;
    try {
        libBytecode = '0x' + fs.readFileSync(binPath).toString();
        var abi = fs.readJsonSync(abiPath);
        this._libs[type] = lib = {abi: abi, bytecode: libBytecode};
    } catch (err) {
        return cb("Library: '" + type + "' missing binary (.bin) or abi (.abi) file in root dir.");
    }

    var that = this;
    // Deploy and link libraries before adding to contracts list.
    this._linkBytecode(libBytecode, function (err, newBytecode) {
        if (err) return callback(err);

        lib.bytecode = newBytecode;
        console.log("Deploying: " + type);

        var cf = that._web3.eth.contract(lib.abi);
        cf.new({data: newBytecode, gas: that._gas}, function (err, ctr) {
            if (err) {
                callback(err);
            } else if (ctr.address) {
                lib.address = ctr.address;
                lib.contract = ctr;
                console.log("Library '" + type + "' deployed at: " + ctr.address);
                cb(null);
            }
        });
    });

};

/**
 * Deploy a contract. Will not register the contract in the deployed contracts registry, nor do
 * any linking. Useful when deploying simple test contracts.
 *
 * @param {string} type - The name of the contract as it appears in the source code.
 * @param {Array} [params] - An array of the constructor params in order.
 * @param {Function} cb - Error-first callback: 'function(error, contract)', where contract is a web3 contract.
 */
Deployer.prototype.deployOnly = function (type, params, cb) {
    var callback;
    if (typeof(params) === 'function') {
        callback = params;
        params = [];
    } else {
        callback = cb;
    }

    var binPath = path.join(this._rootDir, type + ".bin");
    var abiPath = path.join(this._rootDir, type + ".abi");
    var c;

    try {
        var bytecode = '0x' + fs.readFileSync(binPath).toString();
        var abi = fs.readJsonSync(abiPath);
        c = {bytecode: bytecode, abi: abi};
    } catch (err) {
        return callback("Contract: '" + type + "' missing binary (.bin) or abi (.abi) file in root dir.");
    }

    var that = this;
    console.log("Deploying: " + type + 'without linking or registering.');

    var cf = that._web3.eth.contract(c.abi);

    if (!params) {
        params = [];
    }

    var opts = {data: c.bin, gas: that._gas};
    params.push(opts);
    params.push(function (err, ctr) {
        if (err) {
            callback(err);
        } else if (ctr.address) {
            console.log("'" + type + "' deployed at: " + ctr.address);
            callback(null, ctr);
        }
    });
    cf.new.apply(cf, params);
};

/**
 * Called to link all libraries needed for a contract. Libraries that does not
 * exist in the library registry is deployed and recursively linked themselves,
 * if all library .bin and .abi files can be found on the root path.
 *
 * @param {string} bytecode - The bytecode as a hex string.
 * @param {Function} cb - Error first callback: 'function(error, newBytecode)'
 *
 * @private
 */
Deployer.prototype._linkBytecode = function (bytecode, cb) {
    if (bytecode.indexOf('_') < 0) {
        // console.log("No libraries found");
        return cb(null, bytecode);
    }
    var m = bytecode.match(/__([^_]{1,36})__/);
    // console.log("Found library: ");
    // console.log(m);
    if (!m)
        return cb("Invalid bytecode format.");
    var libraryName = m[1];
    if (!this._libs[libraryName]) {

        var binPath = path.join(this._rootDir, libraryName + ".bin");
        var abiPath = path.join(this._rootDir, libraryName + ".abi");

        try {
            var libBytecode = '0x' + fs.readFileSync(binPath).toString();
            var abi = fs.readJsonSync(abiPath);
            this._libs[libraryName] = {abi: abi, bytecode: libBytecode};
        } catch (err) {
            return cb("Library: '" + libraryName + "' missing binary (.bin) or abi (.abi) file in root dir.");
        }
    }
    var that = this;
    this._deployLibrary(libraryName, function (err, address) {
        if (err) return cb(err);

        var libLabel = '__' + libraryName + new Array(39 - libraryName.length).join('_');
        // console.log('libLabel: ' + libLabel);
        var hexAddress = address;
        // console.log("hexAddress: " + hexAddress);
        if (hexAddress.slice(0, 2) == '0x') hexAddress = hexAddress.slice(2);
        hexAddress = new Array(40 - hexAddress.length + 1).join('0') + hexAddress;
        while (bytecode.indexOf(libLabel) >= 0) {
            // console.log("Replacing instance of library: " + libraryName);
            bytecode = bytecode.replace(libLabel, hexAddress);
        }
        // console.log("Binary code edited. New version: " + bytecode);
        that._linkBytecode(bytecode, cb);
    });
};

/**
 * Deploy a library contract and store the data in the library registry.
 *
 * @param {string} name - The name of the library, as it appears in the source code.
 * @param {Function} cb - Error first callback: 'function(error, address)', where address is the
 *                        address of the newly deployed library.
 *
 * @private
 */
Deployer.prototype._deployLibrary = function (name, cb) {
    // console.log("Deploying library: " + name);
    if (this._libs[name].address) {
        // console.log("Library '" + name + "' already deployed at: " + this.libs[name].address.toString('hex'));
        return cb(null, this._libs[name].address);
    }
    var bytecode = this._libs[name].bytecode;
    // console.log("Library bytecode being deployed: " + bytecode);
    var that = this;
    if (bytecode.indexOf('_') >= 0) {
        // console.log("Library inside library detected: " + name);
        this._linkBytecode(bytecode, function (err, newBin) {
            // console.log("Library bytecode pre: " + bytecode);
            // console.log("Library bytecode post: " + newBin);
            if (err)
                return cb(err);
            that._libs[name].bytecode = newBin;
            that._deployLibrary(name, cb);
        });
    }
    else {
        var lib = that._libs[name];
        var cf = that._web3.eth.contract(lib.abi);

        var opts = {data: lib.bytecode, gas: this._gas};

        cf.new(opts, function (err, contract) {
            if (err) {
                cb(err);
            } else if (contract.address) {
                lib.address = contract.address;
                lib.contract = contract;
                console.log("Library '" + name + "' deployed at: " + contract.address);
                cb(null, contract.address);
            }
        });
    }
};

/**
 * Set the root-directory to use when deploying.
 *
 * @param {string} rootDir - The root directory.
 */
Deployer.prototype.setRootDir = function (rootDir) {
    this._rootDir = rootDir;
};

/**
 * Set the address to use when deploying.
 *
 * @param {string} address - The address as a hex-string.
 */
Deployer.prototype.setAddress = function (address) {
    this._address = address;
};

/**
 * Set the gas amount to use when transacting.
 *
 * @param {number|string|Object} gas - The gas as a number, string, or BigNumber.
 */
Deployer.prototype.setGas = function (gas) {
    this._gas = gas;
};

/**
 * Write contract data into a json file.
 *
 * @param {string} fileName         - The filename. Defaults to 'rootDir/contracts.json'.
 * @param {Object} modifyContracts  - Don't overwrite the old contracts file, only modify it.
 * @param {boolean} libraries       - If libraries was deployed as well, set this to 'true' and it will write the
 *                                    deployment file for those as well, and link to the contracts through a timestamp.
 * @param {boolean} libraryFileName - The libraries filename. Defaults to 'rootDir/libraries.json'.
 * @param {Object} modifyLibraries  - Don't overwrite the old libraries file, only modify it.
 *
 * @returns {Object} The contracts object.
 */
Deployer.prototype.writeContracts = function (fileName, modifyContracts, libraries, libraryFileName, modifyLibraries) {

    var fn = fileName || path.join(this._rootDir, "contracts.json");
    var cData;
    if (modifyContracts) {
        cData = fs.readJsonSync(fn);
    } else {
        cData = {contracts: {}};
    }
    var libs = libraries;
    var lfn = libraryFileName || path.join(this._rootDir, "libraries.json");
    var lData;
    if (modifyLibraries) {
        lData = fs.readJsonSync(lfn);
    } else {
        lData = {libraries: {}};
    }

    for (var c in this._contracts) {
        if (this._contracts.hasOwnProperty(c)) {
            var cc = this._contracts[c];
            cData.contracts[c] = {type: cc.type, address: cc.contract.address};
        }
    }

    cData.id = new Date().getTime();

    if (libs) {
        for (var lib in this._libs) {
            if (this._libs.hasOwnProperty(lib)) {
                lData.libraries[lib] = this._libs[lib].address;
            }
        }
        lData.id = cData.id;
        fs.writeJsonSync(lfn, lData);
    }

    fs.writeJsonSync(fn, cData);
    return cData;
};

/**
 * Write contract data into a json file.
 *
 * @param {string} fileName         - The filename. Defaults to 'rootDir/contracts.json'.
 * @param {Object} modifyContracts  - Don't overwrite the old contracts file, only modify it.
 * @param {boolean} libraries       - If libraries was deployed as well, set this to 'true' and it will write the
 *                                    deployment file for those as well, and link to the contracts through a timestamp.
 * @param {boolean} libraryFileName - The libraries filename. Defaults to 'rootDir/libraries.json'.
 * @param {Object} modifyLibraries  - Don't overwrite the old libraries file, only modify it.
 *
 * @returns {Object} The contracts object.
 */
Deployer.prototype.writeContracts = function (fileName, modifyContracts, libraries, libraryFileName, modifyLibraries) {

    var fn = fileName || path.join(this._rootDir, "contracts.json");
    var cData;
    if (modifyContracts) {
        cData = fs.readJsonSync(fn);
    } else {
        cData = {contracts: {}};
    }
    var libs = libraries;
    var lfn = libraryFileName || path.join(this._rootDir, "libraries.json");

    var lData;
    if (modifyLibraries) {
        lData = fs.readJsonSync(lfn);
    } else {
        lData = {libraries: {}};
    }

    for (var c in this._contracts) {
        if (this._contracts.hasOwnProperty(c)) {
            var cc = this._contracts[c];
            cData.contracts[c] = {type: cc.type, address: cc.contract.address, abi: cc.abi, bytecode: cc.bytecode};
        }
    }

    cData.id = new Date().getTime();

    if (libs) {
        for (var lib in this._libs) {
            if (this._libs.hasOwnProperty(lib)) {
                lData.libraries[lib] = this._libs[lib].address;
            }
        }
        lData.id = cData.id;
        fs.writeJsonSync(lfn, lData);
    }

    fs.writeJsonSync(fn, cData);
    return cData;
};

/**
 * Write library data (name, address) into a json file.
 *
 * @param {boolean} fileName        - The libraries filename. Defaults to 'rootDir/libraries.json'.
 * @param {Object} modifyLibraries  - Don't overwrite the old libraries file, only modify it.
 *
 * @returns {Object} The libraries object.
 */
Deployer.prototype.writeLibraries = function (fileName, modifyLibraries) {
    var lfn = fileName || path.join(this._rootDir, "libraries.json");
    var lData;
    if (modifyLibraries) {
        lData = fs.readJsonSync(lfn);
    } else {
        lData = {libraries: {}};
    }
    for (var lib in this._libs) {
        if (this._libs.hasOwnProperty(lib)) {
            lData.libraries[lib] = this._libs[lib].address;
        }
    }
    lData.id = new Date().getTime();
    fs.writeJsonSync(lfn, lData);
    return fn;
};

/**
 * Get the address used when deploying.
 *
 * @returns {string} The address as a hex-string.
 */
Deployer.prototype.address = function () {
    return this._address;
};

/**
 * Get the web3 object used.
 *
 * @returns {Object}
 */
Deployer.prototype.web3 = function () {
    return this._web3;
};

/**
 * Get the contract registry.
 *
 * @returns {Object}
 */
Deployer.prototype.contracts = function () {
    return this._contracts;
};

/**
 * Get the gas value used in transactions.
 *
 * @returns {number|number|string|Object}
 */
Deployer.prototype.gas = function () {
    return this._gas;
};

/**
 * Get the library registry.
 *
 * @returns {Object}
 */
Deployer.prototype.libraries = function () {
    return this._libs;
};

module.exports = Deployer;