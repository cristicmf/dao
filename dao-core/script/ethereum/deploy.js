var fs = require('fs-extra');
var path = require('path');
var async = require('async');
var Deployer = require('../../../script/deployment/deployer.js');

// *************************************************************

function deploy(callback){

    var dir = path.join(__dirname, "../../contracts/build/release");
    var dep = new Deployer(dir ,"http://localhost:8545");

    var perm;
    var doug;

    async.series([deployPermission, testRootSet, deployDoug, testPermSet, write], function(err){
        if(err) throw err;
        console.log("All contracts deployed!");
    });

    function deployPermission(cb){
        dep.deploy("DefaultPermission", [dep.address], function(err, contract){
            if(err) throw err;
            perm = contract;
            cb();
        })
    }

    // Basic check.
    function testRootSet(cb){
        var pRoot = perm.root();
        if(pRoot !== dep.address){
            return cb(new Error("Root address in permission is wrong: " + pRoot));
        }
        console.log("Root permission properly set.");
        cb();
    }

    function deployDoug(cb){
        var permAddr = perm.address;
        dep.deploy("DefaultDoug", [permAddr, false, false], function(err, contract){
            if(err) throw err;
            doug = contract;
            cb();
        })
    }

    // Basic check.
    function testPermSet(cb){
        var dpAddr = doug.permissionAddress();
        var pAddr = perm.address;
        if(dpAddr !== pAddr){
            return cb(new Error("Permission address in doug is wrong: " + dpAddr));
        }
        console.log("Doug permission contract properly set.");
        cb();
    }

    function write(cb){
        fs.writeJsonSync("./doug.json", {doug: doug.address});
        cb();
    }

}

deploy(function(){});