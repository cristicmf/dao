var path = require('path');
var fs = require('fs-extra');
var async = require('async');
var solUnit = require('sol-unit');
var compile = require('./solc');

var DAO_CORE = path.join(__dirname, "../dao-core");
var DAO_CURRENCY = path.join(__dirname, "../dao-currency");
var DAO_STL = path.join(__dirname, "../dao-stl");
var DAO_USERS = path.join(__dirname, "../dao-users");
var DAO_VOTES = path.join(__dirname, "../dao-votes");

var DAO_DEFAULT_INCLUDES = " dao-core=" + DAO_CORE +
    " dao-currency=" + DAO_CURRENCY +
    " dao-stl=" + DAO_STL +
    " dao-users=" + DAO_USERS +
    " dao-votes=" + DAO_VOTES + " ";

function build(rootDir, options, callback) {

    if (typeof(options) === 'function') {
        callback = options;
        options = {};
    }

    // Load build-file.
    var buildFilePath = options.buildFilePath || path.join(rootDir, "build.json");
    var buildFile;
    try {
        buildFile = fs.readJsonSync(buildFilePath);
    } catch (error) {
        console.log("build.json not found, resorting to options");
        buildFile = {};
    }

    buildFile.options = buildFile.options || {};

    // Prepare paths.
    var srcDir = getOption('srcDir', path.join(rootDir, "src"));
    var testDir = getOption('testDir', path.join(rootDir, "test"));

    var buildDir = getOption('buildDir', path.join(rootDir, "build"));

    var buildReleaseDir = path.join(buildDir, "release");
    var buildTestDir = path.join(buildDir, "test");

    // Contracts
    var contracts = buildFile.contracts;

    // Test contracts
    var test = getOption('test');

    if (!contracts && !test) {
        return callback(new Error("No release-contracts were found, and tests aren't flagged."));
    }

    var testContracts = buildFile.testContracts;
    if (test && !testContracts)
        return callback(new Error("Tests were flagged, but no test-contracts found."));

    // Prepare the output directories.
    try {
        fs.removeSync(buildDir);
        fs.emptyDirSync(buildReleaseDir);
        fs.emptyDirSync(buildTestDir);
    } catch (error) {
        return callback(error);
    }

    // Start preparing the command.
    var command = "";

    if (getOption('includeRoot')) {
        command += " .= "
    }

    if (getOption('daoIncludes')) {
        command += DAO_DEFAULT_INCLUDES;
    }

    var includes = buildFile.includes;
    if (includes) {
        for (var inc in includes) {
            if (includes.hasOwnProperty(inc)) {
                command += inc + "=" + path.join(rootDir, includes[inc]);
            }
        }
    }

    if (getOption('bin'))
        command += " --bin ";

    if (getOption('abi'))
        command += " --abi ";

    if (getOption('optimize'))
        command += " --optimize ";
    var or = getOption('optimize-runs');
    if (or)
        command += " --optimize-runs " + or.toString() + " ";


    // One for release, one for test.
    var compileTasks = [];

    var i;

    if (contracts) {
        // For regular build
        var releaseCommand = command + " -o " + buildReleaseDir + " ";
        var cs = [];
        for (i = 0; i < contracts.length; i++)
            cs[i] = path.join(srcDir, contracts[i] + ".sol");

        compileTasks.push(function(cb){
            _compile(releaseCommand, cs, buildReleaseDir, cb);
        });
    }

    if (test) {
        // For building tests.
        var testCommand = command + " -o " + buildTestDir + " ";
        var tcs = [];
        for (i = 0; i < testContracts.length; i++) {
            tcs[i] = path.join(testDir, testContracts[i] + ".sol");
            testContracts[i] = path.basename(testContracts[i]);
        }

        compileTasks.push(function(cb){
            _compile(testCommand, tcs, buildTestDir, cb)
        });

    }

    async.series(compileTasks, function(err){
        if(err) return callback(err);
        if(test){
            solUnit.runTests(testContracts, buildTestDir, true, function (stats) {
                callback(null, stats);
            });
        }
        else
            return callback();
    });

    function getOption(fieldName, dflt) {
        return options[fieldName] || buildFile.options[fieldName] || dflt;
    }
}

function _compile(command, contracts, infoOutputDir, callback) {
    compile(command, contracts, function(error, versionString){
        if (error) return callback(error);
        var buildInfo = {solcVersion: versionString, timestamp: new Date().getTime() / 1000 | 0};
        var buildInfoPath = path.join(infoOutputDir, "build_info.json");
        try {
            fs.writeJsonSync(buildInfoPath, buildInfo);
        } catch (error) {
            return callback(error);
        }
        callback();
    });
}


exports.build = build;