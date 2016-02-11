/**
 * @file public_ballot.js
 * @fileOverview Contract service for 'PublicBallot'.
 * @author Andreas Olofsson (androlo1980@gmail.com)
 * @module dao_votes/public_ballot
 */
"use strict";

var util = require('util');

var Ballot = require('./ballot');
var daoUtils = require('../../script/dao_utils');

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
 * @param {Function} cb - error first callback: function(error, finalize).
 */
PublicBallot.prototype.finalize = function (cb) {
    this._contract.finalize(function(err, ret){
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
 * @param {Function} cb - error first callback: function(error, userDatabase).
 */
PublicBallot.prototype.userDatabase = function (cb) {
    this._contract.userDatabase(cb);
};

/**
 * Get the quorum size.
 *
 * @param {Function} cb - error first callback: function(error, quorum).
 */
PublicBallot.prototype.quorum = function (cb) {
    this._contract.quorum(function(err, ret){
        if (err) return cb(err);
        cb(null, ret.toNumber());
    });
};

module.exports = PublicBallot;