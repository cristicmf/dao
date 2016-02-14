/**
 * @file public_ballot.js
 * @fileOverview Contract service for 'PublicBallot'.
 * @author Andreas Olofsson (androlo1980@gmail.com)
 * @module dao_votes/public_ballot
 */
"use strict";

var util = require('util');

var Ballot = require('./ballot');

/**
 * Service for 'PublicBallot'
 *
 * @param {Object} web3 - A web3 object.
 * @param {Object} contract - A web3 contract instance.
 * @param {number} gas - The amount of gas that will be used in transactions.
 *
 * @constructor
 * @augments module:contract_service:ContractService
 */
function PublicBallot(web3, contract, gas) {
    Ballot.call(this, web3, contract, gas);
}

util.inherits(PublicBallot, Ballot);

/**
 * Get the ballot type.
 *
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, finalize).
 */
PublicBallot.prototype.finalize = function (txData, cb) {
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.finalize(txData, function(err, ret){
        if (err) return cb(err);
        var passed = ret[0];
        var error = ret[1].toNumber();
        var execError = ret[2].toNumber();
        cb(null, passed, error, execError);
    });
};

/**
 * Get the address to the user database.
 *
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, userDatabase).
 */
PublicBallot.prototype.userDatabase = function (txData, cb) {
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.userDatabase(txData, cb);
};

/**
 * Get the quorum size.
 *
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, quorum).
 */
PublicBallot.prototype.quorum = function (txData, cb) {
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.quorum(txData, function(err, ret){
        if (err) return cb(err);
        cb(null, ret.toNumber());
    });
};

module.exports = PublicBallot;