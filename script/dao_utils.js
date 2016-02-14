/**
 * @file dao_utils.js
 * @fileOverview Some utility functions.
 * @author Andreas Olofsson (androlo1980@gmail.com)
 * @module dao_utils
 */
'use strict';

var DEFAULT_GAS = 3000000;
var DEFAULT_ETH_URL = "http://localhost:8545";

var path = require('path');
var fs = require('fs-extra');
var Web3 = require('web3');

/**
 * Get a new web3 instance. Will try the provided address first, then the environment variable DOUG_ROOT,
 * and finally 'web3.eth.coinbase'.
 *
 * @param {string|*} address - An address to use as sender. Defaults to coinbase address if set to null.
 * @param {string} [ethURL="http://localhost:8545"] - url to Ethereum RPC-server.
 *
 * @alias module:dao_utils.web3
 */
function web3(address, ethURL) {
    var web3 = new Web3();
    ethURL = ethURL || DEFAULT_ETH_URL;
    web3.setProvider(new web3.providers.HttpProvider(ethURL));
    var root = address || process.env.DOUG_ROOT || web3.eth.coinbase;
    if (!root) {
        throw new Error("Neither DOUG_ROOT environment variable or eth coinbase is valid. Can't sign transactions.");
    }
    web3.eth.defaultAccount = root;
    return web3;
}

/**
 * Load all contracts in a module. This creates a web3 contract object from each contract listed in the
 * contracts file and adds them to an object, using the contract names as keys, and the web3 contracts as
 * values.
 *
 * @param {Object} web3 - The web3 instance to use when creating contracts.
 * @param {string} contractFile - The contract json file.
 * @returns {Object} - The loaded contracts.
 *
 * @alias module:dao_utils.loadContracts
 */
function loadContracts(web3, contractFile) {

    var contracts = fs.readJsonSync(contractFile);
    var loaded = {};
    for (var c in contracts.contracts) {
        if (contracts.contracts.hasOwnProperty(c)) {
            var cData = contracts.contracts[c];
            var code = web3.eth.getCode(cData.address);
            if(code !== cData.bytecode)
                throw new Error("On-chain bytecode does not match that in the contracts.json file for: " + cData.name + " (" + cData.type + ").");
            loaded[c] = {type: cData.type, contract: web3.eth.contract(cData.abi).at(cData.address)};
        }
    }
    return loaded;
}


/**
 * Get the default gas value: 3'000'000.
 *
 * @returns {number}
 *
 * @alias module:dao_utils.defaultGas
 */
function defaultGas() {
    return DEFAULT_GAS;
}

/**
 * hex-to-ascii. Code is taken from the web3.js utility function 'toAscii'.
 *
 * @param {string} hex - The hex string.
 *
 * @alias module:dao_utils.htoa
 */
function htoa(hex) {
// Find termination
    var str = "";
    var i = 0, l = hex.length;
    if (hex.substring(0, 2) === '0x') {
        i = 2;
    }
    for (; i < l; i += 2) {
        var code = parseInt(hex.substr(i, 2), 16);
        if (code === 0)
            break;
        str += String.fromCharCode(code);
    }

    return str;
}

/**
 * ascii-to-hex. Code is taken from the web3.js utility function 'fromAscii'. Max 32 bytes.
 *
 * @param {string} str - The ASCII string.
 * @param {number} [maxLength] - The maximum length.
 *
 * @alias module:dao_utils.atoh
 */
function atoh(str, maxLength) {
    var hex = "";
    var ml;
    if (!maxLength)
        ml = 32;
    else
        ml = maxLength;
    if (str.length > ml)
        str = str.slice(0, ml);
    for (var i = 0; i < str.length; i++) {
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
 *
 * @alias module:dao_utils.dateToTimestamp
 */
function dateToTimestamp(date) {
    return date.getTime() / 1000 | 0;
}

/**
 * Converts a unix timestamp to a javascript date object.
 *
 * Returns 'null' if the timestamp is 0.
 *
 * @param {number} timestamp - A javascript date object.
 *
 * @alias module:dao_utils.timestampToDate
 */
function timestampToDate(timestamp) {
    if(timestamp === 0) {
        return null;
    }
    return new Date(timestamp * 1000);
}

/**
 * Converts a unix timestamp in BigNumber form to a javascript date object.
 *
 * Returns 'null' if the timestamp is 0.
 *
 * @param {Object} timestamp - A javascript date object.
 *
 * @alias module:dao_utils.bnToDate
 */
function bnToDate(timestamp) {
    var tsNum = timestamp.toNumber();
    if (tsNum === 0) {
        return null;
    }
    return new Date(tsNum * 1000);
}

module.exports = {
    web3: web3,
    loadContracts: loadContracts,
    defaultGas: defaultGas,
    atoh: atoh,
    htoa: htoa,
    dateToTimestamp: dateToTimestamp,
    timestampToDate: timestampToDate,
    bnToDate: bnToDate

};