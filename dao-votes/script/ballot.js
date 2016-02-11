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
 * @param {Function} cb - error first callback: function(error, ballotType).
 */
Ballot.prototype.ballotType = function (cb) {
    this._contract.userDatabase(function(err, btHex){
        if (err) return cb(err);
        cb(null, daoUtils.htoa(btHex));
    });
};

/**
 * Get the ballot id.
 *
 * @param {Function} cb - error first callback: function(error, ballotId).
 */
Ballot.prototype.id = function (cb) {
    this._contract.id(cb);
};

/**
 * Get the address of the ballot creator.
 *
 * @param {Function} cb - error first callback: function(error, creator).
 */
Ballot.prototype.creator = function (cb) {
    this._contract.creator(cb);
};

/**
 * Get the time when the ballot was opened.
 *
 * @param {Function} cb - error first callback: function(error, ballotId).
 */
Ballot.prototype.opened = function (cb) {
    this._contract.opened(function(err, ret){
        if (err) return cb(err);
        cb(null, daoUtils.bnToDate(ret));
    });
};

/**
 * Get the time when the ballot was concluded.
 *
 * @param {Function} cb - error first callback: function(error, ballotId).
 */
Ballot.prototype.concluded = function (cb) {
    this._contract.concluded(function(err, ret){
        if (err) return cb(err);
        cb(null, daoUtils.bnToDate(ret));
    });
};

/**
 * Get the duration of the ballot (in seconds).
 *
 * @param {Function} cb - error first callback: function(error, ballotId).
 */
Ballot.prototype.durationInSeconds = function (cb) {
    this._contract.durationInSeconds(function(err, ret){
        if (err) return cb(err);
        cb(null, ret.toNumber());
    });
};

/**
 * Get the state.
 *
 * @param {Function} cb - error first callback: function(error, ballotId).
 */
Ballot.prototype.state = function (cb) {
    this._contract.state(function(err, ret){
        if (err) return cb(err);
        cb(null, ret.toNumber());
    });
};

/**
 * Get the number of eligible voters.
 *
 * @param {Function} cb - error first callback: function(error, numEligibleVoters).
 */
Ballot.prototype.numEligibleVoters = function (cb) {
    this._contract.numEligibleVoters(cb);
};

/**
 * Get the current number of votes.
 *
 * @param {Function} cb - error first callback: function(error, numVotes).
 */
Ballot.prototype.numVotes = function (cb) {
    this._contract.numVotes(cb);
};

module.exports = Ballot;