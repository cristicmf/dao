var gulp = require('gulp');
var path = require('path');
var process = require('child_process');
var solUnit = require('sol-unit');
var async = require('async');
var natdoc2html = require('./script/natdoc2html/natdoc2html');

/************************ dao-core ***************************/

var daoCoreContracts = ['Database', 'Doug', 'DefaultDoug', 'Permission', 'DefaultPermission'];
var daoCoreTests = ['DefaultPermissionTest', 'DefaultDougTest', 'DefaultDougEnabledTest', 'DefaultDougActionsTest', 'DefaultDougDatabaseTest'];
var daoCoreTestFolder = path.join(__dirname, 'dao-core', 'contracts', 'build', 'test');

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
    natdoc2html('dao-core', daoCoreContracts, './dao-core/contracts/build/docs', './docs/contracts/dao-core', cb);
});

/************************ dao-currency ***************************/

var daoCurrencyContracts = ['AbstractMintedCurrency', 'CurrencyDatabase', 'DefaultCurrencyDatabase', 'DefaultMintedCurrency', 'MintedCurrency', 'MintedUserCurrency'];
var daoCurrencyTests = ['DefaultCurrencyDatabaseTest', 'DefaultMintedCurrencyTest', 'MintedUserCurrencyTest'];
var daoCurrencyTestFolder = path.join(__dirname, 'dao-currency', 'contracts', 'build', 'test');

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
    natdoc2html('dao-currency', daoCurrencyContracts, './dao-currency/contracts/build/docs', './docs/contracts/dao-currency', cb);
});

/************************ dao-users ***************************/

var daoUsersContracts = ['DefaultUserDatabase', 'UserDatabase', 'UserRegistry', 'AbstractUserRegistry', 'AdminRegUserRegistry', 'SelfRegUserRegistry'];
var daoUsersTests = ['DefaultUserDatabaseTest'];
var daoUsersTestFolder = path.join(__dirname, 'dao-users', 'contracts', 'build', 'test');

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
    natdoc2html('dao-users', daoUsersContracts, './dao-users/contracts/build/docs', './docs/contracts/dao-users', cb);
});

/************************ dao-votes ***************************/

var daoVotesContracts = ['Ballot', 'BallotManager', 'BallotMap', 'MintBallot', 'MintBallotManager', 'PublicBallot'];
var daoVotesTests = ['PublicBallotTest'];
var daoVotesTestFolder = path.join(__dirname, 'dao-votes', 'contracts', 'build', 'test');

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
    natdoc2html('dao-votes', daoVotesContracts, './dao-votes/contracts/build/docs', './docs/contracts/dao-votes', cb);
});

/************************ all ***************************/

gulp.task('build:all', ['build:core', 'build:currency', 'build:users', 'build:votes']);

gulp.task('test:all', function (cb) {
    var total = 0;
    var successful = 0;

    async.series([
            function (cb) {
                solUnit.runTests(daoCoreTests, daoCoreTestFolder, true, function (stats) {
                    total += stats.total;
                    successful += stats.successful;
                    cb();
                });
            }, function (cb) {
                solUnit.runTests(daoCurrencyTests, daoCurrencyTestFolder, true, function (stats) {
                    total += stats.total;
                    successful += stats.successful;
                    cb();
                });
            }, function (cb) {
                solUnit.runTests(daoUsersTests, daoUsersTestFolder, true, function (stats) {
                    total += stats.total;
                    successful += stats.successful;
                    cb();
                });
            }, function (cb) {
                solUnit.runTests(daoVotesTests, daoVotesTestFolder, true, function (stats) {
                    total += stats.total;
                    successful += stats.successful;
                    cb();
                });
            }], function () {
            console.log("");
            console.log("Total tests: " + total);
            console.log("Successful: " + successful);
            console.log("Failed: " + (total - successful).toString());
            cb();
        }
    );

});

gulp.task('htmldoc:all', ['htmldoc:core', 'htmldoc:currency', 'htmldoc:users', 'htmldoc:votes']);