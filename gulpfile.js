var gulp = require('gulp');
var path = require('path');
var process = require('child_process');
var solUnit = require('sol-unit');
var async = require('async');

/************************ dao-core ***************************/

var daoCoreTests = ['DefaultPermissionTest', 'DefaultDougTest', 'DefaultDougEnabledTest', 'DefaultDougActionsTest', 'DefaultDougDatabaseTest'];
var daoCoreTestFolder = path.join(__dirname, 'dao-core', 'build', 'test');

gulp.task('build:core', function (cb) {
    process.exec('./build_contracts.sh dao-core', function (error) {
        if (error)
            throw new Error(error);
        cb();
    });
});

gulp.task('test:core', function (cb) {
    solUnit.runTests(daoCoreTests, daoCoreTestFolder, true, function (stats) {
        var failed = stats.total - stats.successful;
        if (failed !== 0)
            throw new Error("Tests failed: " + failed);
        cb();
    });
});

gulp.task('htmldoc:core', function(cb){
    process.exec('./build_docs.sh dao-core', function (error) {
        if (error)
            throw new Error(error);
        cb(error);
    });
});

/************************ dao-currency ***************************/

var daoCurrencyTests = ['DefaultCurrencyDatabaseTest', 'AbstractMintedCurrencyTest', 'DefaultMintedCurrencyTest', 'MintedUserCurrencyTest'];
var daoCurrencyTestFolder = path.join(__dirname, 'dao-currency', 'build', 'test');

gulp.task('build:currency', function (cb) {
    process.exec('./build_contracts.sh dao-currency', function (error) {
        if (error)
            throw new Error(error);
        cb(error);
    });
});

gulp.task('test:currency', function (cb) {
    solUnit.runTests(daoCurrencyTests, daoCurrencyTestFolder, true, function (stats) {
        var failed = stats.total - stats.successful;
        if (failed !== 0)
            throw new Error("Tests failed: " + failed);
        cb();
    });
});

gulp.task('htmldoc:currency', function(cb){
    process.exec('./build_docs.sh dao-currency', function (error) {
        if (error)
            throw new Error(error);
        cb(error);
    });
});

/************************ dao-stl ***************************/

var daoSTLTests = ['AddressSetTest', 'PropertySetTest', 'PropertyToAddressTest'];
var daoSTLTestFolder = path.join(__dirname, 'dao-stl', 'build', 'test');

gulp.task('build:stl', function (cb) {
    process.exec('./build_contracts.sh dao-stl', function (error) {
        if (error)
            throw new Error(error);
        cb(error);
    });
});

gulp.task('test:stl', function (cb) {
    solUnit.runTests(daoSTLTests, daoSTLTestFolder, true, function (stats) {
        var failed = stats.total - stats.successful;
        if (failed !== 0)
            throw new Error("Tests failed: " + failed);
        cb();
    });
});

gulp.task('htmldoc:stl', function(cb){
    process.exec('./build_docs.sh dao-stl', function (error) {
        if (error)
            throw new Error(error);
        cb(error);
    });
});

/************************ dao-users ***************************/

var daoUsersTests = ['DefaultUserDatabaseTest', 'AbstractUserRegistryTest', 'AdminRegUserRegistryTest', 'SelfRegUserRegistryTest'];
var daoUsersTestFolder = path.join(__dirname, 'dao-users', 'build', 'test');

gulp.task('build:users', function (cb) {
    process.exec('./build_contracts.sh dao-users', function (error) {
        if (error)
            throw new Error(error);
        cb(error);
    });
});

gulp.task('test:users', function (cb) {
    solUnit.runTests(daoUsersTests, daoUsersTestFolder, true, function (stats) {
        var failed = stats.total - stats.successful;
        if (failed !== 0)
            throw new Error("Tests failed: " + failed);
        cb();
    });
});

gulp.task('htmldoc:users', function(cb){
    process.exec('./build_docs.sh dao-users', function (error) {
        if (error)
            throw new Error(error);
        cb(error);
    });
});

/************************ dao-votes ***************************/

var daoVotesTests = ['BallotMapTest', 'PublicBallotTest', 'PublicMintingBallotTest', 'PublicCurrencyBasicTest', 'PublicCurrencyMintingTest', 'PublicCurrencyDurationTest', 'PublicCurrencyQuorumTest', 'PublicCurrencyKeepDurationTest'];
var daoVotesTestFolder = path.join(__dirname, 'dao-votes', 'build', 'test');

gulp.task('build:votes', function (cb) {
    process.exec('./build_contracts.sh dao-votes', function (error) {
        if (error)
            throw new Error(error);
        cb(error);
    });
});

gulp.task('test:votes', function (cb) {
    solUnit.runTests(daoVotesTests, daoVotesTestFolder, true, function (stats) {
        var failed = stats.total - stats.successful;
        if (failed !== 0)
            throw new Error("Tests failed: " + failed);
        cb();
    });
});

gulp.task('htmldoc:votes', function(cb){
    process.exec('./build_docs.sh dao-votes', function (error) {
        if (error)
            throw new Error(error);
        cb(error);
    });
});

/************************ all ***************************/

gulp.task('build:all', ['build:core', 'build:currency', 'build:stl', 'build:users', 'build:votes']);

gulp.task('test:all', function (cb) {
    var total = 0;
    var successful = 0;
    var units = 0;
    var skipped = 0;

    async.series([
            function (cb) {
                solUnit.runTests(daoCoreTests, daoCoreTestFolder, true, function (stats) {
                    total += stats.total;
                    successful += stats.successful;
                    units += stats.numTestUnits;
                    skipped += stats.numSkippedUnits;
                    cb();
                });
            }, function (cb) {
                solUnit.runTests(daoCurrencyTests, daoCurrencyTestFolder, true, function (stats) {
                    total += stats.total;
                    successful += stats.successful;
                    units += stats.numTestUnits;
                    skipped += stats.numSkippedUnits;
                    cb();
                });
            }, function (cb) {
                solUnit.runTests(daoSTLTests, daoSTLTestFolder, true, function (stats) {
                    total += stats.total;
                    successful += stats.successful;
                    units += stats.numTestUnits;
                    skipped += stats.numSkippedUnits;
                    cb();
                });
            }, function (cb) {
                solUnit.runTests(daoUsersTests, daoUsersTestFolder, true, function (stats) {
                    total += stats.total;
                    successful += stats.successful;
                    units += stats.numTestUnits;
                    skipped += stats.numSkippedUnits;
                    cb();
                });
            }, function (cb) {
                solUnit.runTests(daoVotesTests, daoVotesTestFolder, true, function (stats) {
                    total += stats.total;
                    successful += stats.successful;
                    units += stats.numTestUnits;
                    skipped += stats.numSkippedUnits;
                    cb();
                });
            }], function () {
            console.log("");
            console.log("****************************************");
            console.log("Total units: " + units);
            console.log("Skipped: " + skipped);
            console.log("");
            console.log("Total tests: " + total);
            console.log("Successful: " + successful);
            console.log("Failed: " + (total - successful).toString());
            console.log("****************************************");
            console.log("");
            cb();
        }
    );

});

gulp.task('htmldoc:all', ['htmldoc:core', 'htmldoc:currency', 'htmldoc:stl', 'htmldoc:users', 'htmldoc:votes']);