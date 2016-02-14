/**
 * @file ballot.js
 * @fileOverview Contract service for 'Ballot'.
 * @author Andreas Olofsson (androlo1980@gmail.com)
 * @module dao_votes/ballot
 */
"use strict";

var util = require('util');

var ContractService = require('../../script/contract_service');
var daoUtils = require('../../script/dao_utils');

/**
 * Service for 'Ballot'
 *
 * @param {Object} web3 - A web3 object.
 * @param {Object} contract - A web3 contract instance.
 * @param {number} gas - The amount of gas that will be used in transactions.
 *
 * @constructor
 * @augments module:contract_service:ContractService
 */
function Ballot(web3, contract, gas) {
    ContractService.call(this, web3, contract, gas);
}

util.inherits(Ballot, ContractService);


/**
 * Get the ballot type.
 *
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, ballotType).
 */
Ballot.prototype.ballotType = function (txData, cb) {
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.userDatabase(txData, function(err, btHex){
        if (err) return cb(err);
        cb(null, daoUtils.htoa(btHex));
    });
};

/**
 * Get the ballot id.
 *
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, ballotId).
 */
Ballot.prototype.id = function (txData, cb) {
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.id(txData, cb);
};

/**
 * Get the address of the ballot creator.
 *
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, creator).
 */
Ballot.prototype.creator = function (txData, cb) {
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.creator(txData, cb);
};

/**
 * Get the time when the ballot was opened.
 *
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, ballotId).
 */
Ballot.prototype.opened = function (txData, cb) {
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.opened(txData, function(err, ret){
        if (err) return cb(err);
        cb(null, daoUtils.bnToDate(ret));
    });
};

/**
 * Get the time when the ballot was concluded.
 *
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, concluded).
 */
Ballot.prototype.concluded = function (txData, cb) {
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.concluded(txData, function(err, ret){
        if (err) return cb(err);
        cb(null, daoUtils.bnToDate(ret));
    });
};

/**
 * Get the duration of the ballot (in seconds).
 *
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, durationInSeconds).
 */
Ballot.prototype.durationInSeconds = function (txData, cb) {
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.durationInSeconds(txData, function(err, ret){
        if (err) return cb(err);
        cb(null, ret.toNumber());
    });
};

/**
 * Get the state.
 *
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, state).
 */
Ballot.prototype.state = function (txData, cb) {
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.state(txData, function(err, ret){
        if (err) return cb(err);
        cb(null, ret.toNumber());
    });
};

/**
 * Get the number of eligible voters.
 *
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, numEligibleVoters).
 */
Ballot.prototype.numEligibleVoters = function (txData, cb) {
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.numEligibleVoters(txData, cb);
};

/**
 * Get the current number of votes.
 *
 * @param {Object} [txData] - tx data.
 * @param {Function} cb - error first callback: function(error, numVotes).
 */
Ballot.prototype.numVotes = function (txData, cb) {
    if (typeof(txData) === 'function') {
        cb = txData;
        txData = this._txData(null);
    }
    else
        txData = this._txData(txData);
    this._contract.numVotes(txData, cb);
};

module.exports = Ballot;