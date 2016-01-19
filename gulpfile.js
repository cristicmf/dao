var gulp = require('gulp');
var path = require('path');
var process = require('child_process');
var solUnit = require('sol-unit');

/************************ dao-core ***************************/

var daoCoreTests = ['DefaultPermissionTest', 'DougTest', 'DougEnabledTest','DougActionsTest', 'DougDatabaseTest'];
var daoCoreTestFolder = path.join(__dirname, 'dao-core', 'contracts', 'build', 'test');

gulp.task('build-dao-core', function(cb) {
    process.exec('./build_contracts.sh dao-core', function (error) {
        if(error) return cb(error);
    });
});

gulp.task('test-dao-core', function(cb) {
    solUnit.runTests(daoCoreTests, daoCoreTestFolder, true, function(stats){
       var failed = stats.total - stats.successful;
       if(failed !== 0){
           throw new Error("Tests failed: " + failed);
       }
       cb();
    });
});

/************************ dao-users ***************************/

var daoUsersTests = ['UserDatabaseTest'];
var daoUsersTestFolder = path.join(__dirname, 'dao-users', 'contracts', 'build', 'test');

gulp.task('build-dao-users', function(cb) {
    process.exec('./build_contracts.sh dao-users', function (error) {
        if(error) return cb(error);
    });
});

gulp.task('test-dao-users', function(cb) {
    solUnit.runTests(daoUsersTests, daoUsersTestFolder, true, function(stats){
        var failed = stats.total - stats.successful;
        if(failed !== 0){
            throw new Error("Tests failed: " + failed);
        }
        cb();
    });
});