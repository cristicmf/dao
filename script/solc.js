/**
 * @file solc.js
 * @fileOverview Calls command-line solc.
 * @author Andreas Olofsson (androlo1980@gmail.com)
 * @module solc
 */
'use strict';
var process = require('child_process');

/**
 * Calls command-line solc. The command has three parts.
 *
 * 1. 'solc', which is added automatically.
 * 2. 'options', which includes all the options, e.g. ".= --bin -o ./build"
 * 3. 'files', which is the input files.
 *
 * @param {string} commandOptions - The options as a string. Do not include 'solc' or any input files.
 * @param {string[]} files - All input files as an array of strings.
 * @param {Function} callback - Error first callback. 'function(error, compilerVersionString)'
 *
 * @alias module:solc.compile
 */
function compile(commandOptions, files, callback) {
    if (!files)
        return callback(new Error("No file-names provided."));
    var versionStr;

    process.exec('solc --version', function (error, stdout, stderr) {
        if (error)
            return callback(error);
        if (stderr)
            return callback(new Error("Solc error: " + stderr.toString()));
        var soSplit = stdout.trim('\n').split('\n');
        if(soSplit.length != 2)
            return callback(new Error("Solc version output malformed: " + stdout));
        versionStr = soSplit[1];

        var filesStr = " ";
        for(var i = 0; i < files.length; i++) {
            filesStr += files[i] + " ";
        }

        process.exec('solc ' + commandOptions + filesStr, function (error, stdout, stderr) {
            if (error)
                return callback(error);
            if (stderr)
                return callback(new Error("Solc error: " + stderr.toString()));
            callback(null, versionStr, stdout);
        });
    });

}

module.exports = compile;