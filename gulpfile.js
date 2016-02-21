var gulp = require('gulp');
var path = require('path');

var builder = require('./script/builder');
var async = require('async');

/************************ dao-core ***************************/

gulp.task('build:core', function (cb) {
    builder.build('dao-core', {test: true}, function (error, stats) {
        if (error) return cb(error);
        var failed = stats.total - stats.successful;
        if (failed !== 0)
            throw new Error("Tests failed: " + failed);
        cb();
    });
});

/************************ dao-currency ***************************/

gulp.task('build:currency', function (cb) {
    builder.build('dao-currency', {test: true}, function (error, stats) {
        if (error) return cb(error);
        var failed = stats.total - stats.successful;
        if (failed !== 0)
            throw new Error("Tests failed: " + failed);
        cb();
    });
});

/************************ dao-stl ***************************/

gulp.task('build:stl', function (cb) {
    builder.build('dao-stl', {test: true}, function (error, stats) {
        if (error) return cb(error);
        var failed = stats.total - stats.successful;
        if (failed !== 0)
            throw new Error("Tests failed: " + failed);
        cb();
    });
});

/************************ dao-users ***************************/

gulp.task('build:users', function (cb) {
    builder.build('dao-users', {test: true}, function (error, stats) {
        if (error) return cb(error);
        var failed = stats.total - stats.successful;
        if (failed !== 0)
            throw new Error("Tests failed: " + failed);
        cb();
    });
});

/************************ dao-votes ***************************/

gulp.task('build:votes', function (cb) {
    builder.build('dao-votes', {test: true}, function (error, stats) {
        if (error) return cb(error);
        var failed = stats.total - stats.successful;
        if (failed !== 0)
            throw new Error("Tests failed: " + failed);
        cb();
    });
});

/************************ public currency example ***************************/

gulp.task('build:examples', function (cb) {
    builder.build('examples/contracts/public_currency', {test: true, includes: {'public-currency': path.join(__dirname, 'examples/contracts/public_currency')}}, function (error, stats) {
        if (error) return cb(error);
        var failed = stats.total - stats.successful;
        if (failed !== 0)
            throw new Error("Tests failed: " + failed);
        cb();
    });
});

/************************ all ***************************/

gulp.task('build:all', function (cb) {
    var total = 0;
    var successful = 0;
    var units = 0;
    var skipped = 0;

    async.series([
            function (cb) {
                builder.build('dao-core', {test: true}, function (error, stats) {
                    if (error) return cb(error);
                    total += stats.total;
                    successful += stats.successful;
                    units += stats.numTestUnits;
                    skipped += stats.numSkippedUnits;
                    cb();
                });
            }, function (cb) {
                builder.build('dao-currency', {test: true}, function (error, stats) {
                    if (error) return cb(error);
                    total += stats.total;
                    successful += stats.successful;
                    units += stats.numTestUnits;
                    skipped += stats.numSkippedUnits;
                    cb();
                });
            }, function (cb) {
                builder.build('dao-stl', {test: true}, function (error, stats) {
                    if (error) return cb(error);
                    total += stats.total;
                    successful += stats.successful;
                    units += stats.numTestUnits;
                    skipped += stats.numSkippedUnits;
                    cb();
                });
            }, function (cb) {
                builder.build('dao-users', {test: true}, function (error, stats) {
                    if (error) return cb(error);
                    total += stats.total;
                    successful += stats.successful;
                    units += stats.numTestUnits;
                    skipped += stats.numSkippedUnits;
                    cb();
                });
            }, function (cb) {
                builder.build('dao-votes', {test: true}, function (error, stats) {
                    if (error) return cb(error);
                    total += stats.total;
                    successful += stats.successful;
                    units += stats.numTestUnits;
                    skipped += stats.numSkippedUnits;
                    cb();
                });
            }, function (cb) {
                builder.build('examples/contracts/public_currency', {test: true}, function (error, stats) {
                    if (error) return cb(error);
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