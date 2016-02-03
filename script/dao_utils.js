function htoa(hex) {
// Find termination
    var str = "";
    var i = 0, l = hex.length;
    if (hex.substring(0, 2) === '0x') {
        i = 2;
    }
    for (; i < l; i+=2) {
        var code = parseInt(hex.substr(i, 2), 16);
        if (code === 0)
            break;
        str += String.fromCharCode(code);
    }

    return str;
}

function atoh(str) {
    var hex = "";
    for(var i = 0; i < str.length; i++) {
        var code = str.charCodeAt(i);
        var n = code.toString(16);
        hex += n.length < 2 ? '0' + n : n;
    }

    return "0x" + hex;
}

function dateToTimestamp(date) {
    return date.getTime() / 1000 | 0;
}

function timestampToDate(timestamp) {
    return new Date(timestamp*1000);
}

function bnToDate(timestamp) {
    return new Date(timestamp.toNumber()*1000);
}

module.exports.atoh = atoh;

module.exports.htoa = htoa;

module.exports.dateToTimestamp = dateToTimestamp;

module.exports.timestampToDate = timestampToDate;

module.exports.bnToDate = bnToDate;