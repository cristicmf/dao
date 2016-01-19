var gulp = require('gulp');
var path = require('path');
var deployModule = require('./script/ethereum/deploy.js');
var process = require('child_process');
var solUnit = require('sol-unit');

var tests = ['DefaultPermissionTest', 'DougTest', 'DougEnabledTest','DougActionsTest', 'DougDatabaseTest'];
var testFolder = path.join(__dirname, 'contracts', 'build', 'test');

gulp.task('clean-contracts', function(cb) {
    process.exec('make clean', {cwd: './contracts'}, function (error) {
        cb(error);
    });
});

gulp.task('build-contracts', function(cb) {
    process.exec('make clean', {cwd: './contracts'}, function (error) {
        if(error) return cb(error);
        process.exec('make', {cwd: './contracts'}, function (error) {
            cb(error);
        });
    });
});

gulp.task('collections-contracts', function(cb) {
    solUnit.runTests(tests, testFolder, true, function(stats){
       var failed = stats.total - stats.successful;
       if(failed !== 0){
           throw new Error("Tests failed: " + failed);
       }
       cb();
    });
});

gulp.task('deploy_eth', function(cb){
    deployModule.deploy(cb);
});