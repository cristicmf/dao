var process = require('child_process');


function compile(command, files, callback) {
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

        process.exec('solc ' + command + filesStr, function (error, stdout, stderr) {
            if (error)
                return callback(error);
            if (stderr)
                return callback(new Error("Solc error: " + stderr.toString()));
            callback(null, versionStr, stdout);
        });
    });

}

module.exports = compile;