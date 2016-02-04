/**
 * @file dao_utils.js
 * @fileOverview Some utility functions.
 * @author Andreas Olofsson (androlo1980@gmail.com)
 * @module dao_utils
 */
'use strict';

/**
 * hex-to-ascii. Code is taken from the web3.js utility function 'toAscii'.
 *
 * @param {string} hex - The hex string.
 */
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

/**
 * ascii-to-hex. Code is taken from the web3.js utility function 'fromAscii'.
 *
 * @param {string} str - The ASCII string.
 */
function atoh(str) {
    var hex = "";
    for(var i = 0; i < str.length; i++) {
        var code = str.charCodeAt(i);
        var n = code.toString(16);
        hex += n.length < 2 ? '0' + n : n;
    }

    return "0x" + hex;
}

/**
 * Converts a javascript date object to a unix timestamp.
 *
 * @param {Object} date - A javascript date object.
 */
function dateToTimestamp(date) {
    return date.getTime() / 1000 | 0;
}

/**
 * Converts a unix timestamp to a javascript date object.
 *
 * @param {Object} timestamp - A javascript date object.
 */
function timestampToDate(timestamp) {
    return new Date(timestamp*1000);
}

/**
 * Converts a unix timestamp in BigNumber form to a javascript date object.
 *
 * @param {Object} timestamp - A javascript date object.
 */
function bnToDate(timestamp) {
    return new Date(timestamp.toNumber()*1000);
}

module.exports.atoh = atoh;

module.exports.htoa = htoa;

module.exports.dateToTimestamp = dateToTimestamp;

module.exports.timestampToDate = timestampToDate;

module.exports.bnToDate = bnToDate;