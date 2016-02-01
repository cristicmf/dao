'use strict';

var async = require('async');
var fs = require('fs-extra');
var Web3 = require('web3');
var path = require('path');

var DEFAULT_GAS = 3000000;

var DEFAULT_ETH_URL = "http://localhost:8545";

function Deployer(rootDir, ethURL, gas) {
    this.rootDir = rootDir;
    this.libs = {};
    this._contracts = {};
    this._gas = gas || DEFAULT_GAS;
    var web3 = new Web3();
    web3.setProvider(new web3.providers.HttpProvider(ethURL));
    var root = process.env.DOUG_ROOT || web3.eth.coinbase;
    if(!root){
        throw new Error("Neither DOUG_ROOT environment variable or eth coinbase is valid. Can't sign transactions.");
    }
    web3.eth.defaultAccount = root;
    this._address = root;
    this._web3 = web3;
}

Deployer.prototype.deploy = function(contract, params, cb){

    var binPath = path.join(this.rootDir, contract + ".bin");
    var abiPath = path.join(this.rootDir, contract + ".abi");

    try {
        var bytecode = '0x' + fs.readFileSync(binPath).toString();
        var abi = fs.readJsonSync(abiPath);
        this._contracts[contract] = {bytecode: bytecode, abi: abi};
    } catch (err) {
        return cb("Contract: '" + contract + "' missing binary (.bin) or abi (.abi) file in root dir.");
    }

    var that = this;
    // Deploy and link libraries before pushing onto
    this._linkBytecode(bytecode, function(err, newBytecode){
        if(err) return cb(err);
        var cObj = that._contracts[contract];
        cObj.bytecode = newBytecode;
        console.log("Deploying: " + contract);

        var cf = that._web3.eth.contract(cObj.abi);

        if(!params){
            params = [];
        }

        var opts = {data: newBytecode, gas: that._gas};
        params.push(opts);
        params.push(function (err, ctr) {
            if(err) {
                cb(err);
            } else if(ctr.address){
                cObj.contract = ctr;
                console.log("'" + contract + "' deployed at: " + ctr.address);
                cb(null, ctr);
            }
        });
        cf.new.apply(cf, params);
    });

};

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
    if (!this.libs[libraryName]) {

        var binPath = path.join(this.rootDir, libraryName + ".bin");
        var abiPath = path.join(this.rootDir, libraryName + ".abi");

        try {
            var libBytecode = '0x' + fs.readFileSync(binPath).toString();
            var abi = fs.readJsonSync(abiPath);
            this.libs[libraryName] = {abi: abi, bytecode: libBytecode};
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

Deployer.prototype._deployLibrary = function (name, cb) {
    // console.log("Deploying library: " + name);
    if (this.libs[name].address) {
        // console.log("Library '" + name + "' already deployed at: " + this.libs[name].address.toString('hex'));
        return cb(null, this.libs[name].address);
    }
    var bytecode = this.libs[name].bytecode;
    // console.log("Library bytecode being deployed: " + bytecode);
    var that = this;
    if (bytecode.indexOf('_') >= 0) {
        // console.log("Library inside library detected: " + name);
        this._linkBytecode(bytecode, function (err, newBin) {
            // console.log("Library bytecode pre: " + bytecode);
            // console.log("Library bytecode post: " + newBin);
            if (err)
                return cb(err);
            that.libs[name].bytecode = newBin;
            that._deployLibrary(name, cb);
        });
    }
    else {
        var lib = that.libs[name];
        var cf = that._web3.eth.contract(lib.abi);

        var opts = {data: lib.bytecode, gas: this._gas};

        cf.new(opts, function (err, contract) {
            if(err) {
                cb(err);
            } else if(contract.address){
                lib.address = contract.address;
                lib.contract = contract;
                console.log("Library '" +name + "' deployed at: " + contract.address);
                cb(null, contract.address);
            }
        });
    }
};

Deployer.prototype.address = function() {
    return this._address;
};

Deployer.prototype.web3 = function() {
    return this._web3;
};

Deployer.prototype.contracts = function() {
    return this._contracts;
};

Deployer.prototype.gas = function() {
    return this._gas;
};

module.exports = Deployer;