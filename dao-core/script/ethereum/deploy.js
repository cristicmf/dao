var fs = require('fs-extra');
var path = require('path');
var async = require('async');
var Web3 = require('web3');

var GAS = 3000000;

// *****************

exports.deploy = deploy;

function deploy(){

    var root;
    var contracts = {};

    var web3 = new Web3();
    web3.setProvider(new web3.providers.HttpProvider("http://localhost:8545"));
    root = process.env.DOUG_ROOT || web3.eth.coinbase;
    if(!root){
        throw new Error("No signer.");
    }
    web3.eth.defaultAccount = root;

    async.series([deployPermission, testRootSet, deployDoug, testPermSet, write], function(err){
        if(err) throw err;
        console.log("All contracts deployed!");
    });

    function deployPermission(cb){
        _deployContract("DefaultPermission", root, [root], function(err){
            if(err) throw err;
            cb();
        })
    }

    // Basic check.
    function testRootSet(cb){
        var pRoot = contracts["DefaultPermission"].root();
        if(pRoot !== root){
            return cb(new Error("Root address in permission is wrong: " + pRoot));
        }
        console.log("Root permission properly set.");
        cb();
    }

    function deployDoug(cb){
        var permAddr = contracts["DefaultPermission"].address;
        _deployContract("DefaultDoug", root, [permAddr, false], function(err, contract){
            if(err) throw err;
            cb();
        })
    }

    // Basic check.
    function testPermSet(cb){
        var dpAddr = contracts["DefaultDoug"].permissionAddress();
        var pAddr = contracts["DefaultPermission"].address;
        if(dpAddr !== pAddr){
            return cb(new Error("Permission address in doug is wrong: " + dpAddr));
        }
        console.log("Doug permission contract properly set.");
        cb();
    }

    function write(cb){
        fs.writeJsonSync("./doug.json", {doug: contracts["DefaultDoug"].address});
        cb();
    }

    function _deployContract(name, from, params, cb){

        console.log("Deploying: " + name);
        var abi = loadAbi(name);
        var bin = loadBinary(name);
        var cf = web3.eth.contract(abi);

        if(!params){
            params = [];
        }

        var opts = {from: from, data: bin, gas: GAS};
        params.push(opts);
        params.push(function (err, contract) {
            if(err) {
                cb(err);
            } else if(contract.address){
                contracts[name] = contract;
                console.log(name + " deployed at: " + contract.address);
                cb(null);
            }
        });
        cf.new.apply(cf, params);
    }

}

// *****************

function loadAbi(name){
    var dir = path.join(__dirname, "../../contracts/build/release", name + ".abi");
    return fs.readJsonSync(dir);
}

function loadBinary(name){
    var dir = path.join(__dirname, "../../contracts/build/release", name + ".bin");
    return fs.readFileSync(dir).toString();
}

