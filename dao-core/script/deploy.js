var async = require('async');

var Doug = require('./doug');
var Permission = require('./permission');

// *************************************************************

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

module.exports = deploy;
