var fs = require('fs-extra');
var path = require('path');

function getAllFiles(files, rootDir, cb) {
    var matches = {};
    for (var i = 0; i < files.length; i++) {
        matches[files[i]] = true;
    }
    var items = []; // files, directories, symlinks, etc
    fs.walk(rootDir)
        .on('data', function (item) {

            if (item.stats.isFile()) {
                var ext = path.extname(item.path);

                if (ext === '.docdev') {
                    var base = path.basename(item.path, '.docdev');
                    if (matches[base]) {
                        var docs = fs.readJsonSync(item.path);
                        items.push(docs);
                    }
                }
            }
        })
        .on('end', function () {
            cb(items);
        });
}

function genHtml(title, files, docsjson) {
    var html = head(title);
    html += body(title, files, docsjson);
    return html;
}

function head(title) {
    return '<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><meta http-equiv="X-UA-Compatible" content="IE=edge"><meta name="viewport" content="width=device-width, initial-scale=1"><title>' + title + '</title><link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous"><link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap-theme.min.css" integrity="sha384-fLW2N01lMqjakBkx3l/M9EahuwpSfeNvV63J5ezn3uZzapT0u7EYsXMjQV+0En5r" crossorigin="anonymous"><link href="css/natdoc2html.css" rel="stylesheet"></head>';
}

function body(title, files, docsjson) {
    var body = '<body><div class="wrapper">';
    body += generateSidebar(title, files);
    body += '<div id="page-content-wrapper">';
    body += header(title);
    body += '<h3>NOTE: Ethereum Natspec does not support a lot of documentation tags yet. Will improve these pages as it improves. Will also improve the page layout.</h3><br>';
    for (var i = 0; i < docsjson.length; i++) {
        body += generatePanel(docsjson[i]);
    }
    body += '</div></div>';
    body += '<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script><script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js" integrity="sha384-0mSbJDEHialfmuBBQP6A4Qrprq5OVfW37PRR3j5ELqxss1yVqOtnepnHVP9aJ7xS" crossorigin="anonymous"></script></body></html>';
    return body;
}

function generateSidebar(title, files) {
    var sidebar = '<div id="sidebar-wrapper"><ul class="sidebar-nav"><li class="sidebar-brand"><a href="#">' + title + '</a></li>';
    for (var i = 0; i < files.length; i++) {
        var name = files[i];
        sidebar += '<li><a href="#' + name + '">' + name + '</a>';
    }
    sidebar += '</ul></div>';
    return sidebar;
}

function header(header) {
    return '<h1>' + header + '</h1><hr>';
}

function generatePanel(docjson) {
    var title = docjson.title;
    var panel = '<a name="' + title + '"></a>';
    panel += '<div class="panel panel-default"><div class="panel-heading"><h2 class="panel-title">' + title + '</h2></div>';
    panel += '<div class="panel-body">' + "Author: " + docjson.author;
    panel += '</div>';
    panel += '<ul class="list-group">' + generateFuncs(docjson.methods) + '</ul>';
    panel += '</div>';
    return panel;
}

function generateFuncs(methods) {
    var funcs = "";
    for (var m in methods) {
        var method = methods[m];
        funcs += '<li class="list-group-item">';
        funcs += '<div><h4><b>' + m + '</b></h4>';
        funcs += '<div>' + method.details + '</div>';
        if (method.params) {
            funcs += '<div><br><b>Params</b><ul>';
            for (var p in method.params) {
                funcs += '<li><em>' + p + "</em>: " + method.params[p] + '</li>';
            }
            funcs += '</ul></div>';
        }
        if (method.return) {
            funcs += '<div><br><b>Returns</b><ul>';
            var returns = returnsFromReturn(method.return);
            for (var r in returns) {
                funcs += '<li><em>' + r + "</em>: " + returns[r] + '</li>';
            }
            funcs += '</ul></div>';
        }
        funcs += '</div></li>';
    }

    return funcs;
}

function returnsFromReturn(ret) {
    var returnsObj = {};
    var returns = splitReturn(ret);
    for (var i = 0; i < returns.length; i++) {
        var obj = createReturn(returns[i]);
        returnsObj[obj.name] = obj.desc;
    }
    return returnsObj;
}

function splitReturn(ret) {
    return ret.split('|');
}

function createReturn(retString) {
    retString = retString.trim();
    var firstSpace = retString.indexOf(' ');
    var name = retString.substring(0, firstSpace);
    var desc = retString.substr(firstSpace + 1);
    return {name: name, desc: desc};
}

function generate(title, files, docsDir, outputDir, callback) {
    getAllFiles(files, docsDir, function (items) {
        var html = genHtml(title, files, items);
        var op = path.resolve(process.cwd(), outputDir);
        var css = path.join(op, "css");
        fs.ensureDirSync(op);
        fs.writeFileSync(path.join(op, 'index.html'), html);
        fs.copySync(path.join(__dirname, "css"), css);
        callback();
    });
}

module.exports = generate;