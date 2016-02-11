/**
 * @file dao_votes.js
 * @fileOverview dao-votes script.
 * @author Andreas Olofsson (androlo1980@gmail.com)
 * @module dao_votes
 */
"use strict";

var Ballot = require('./ballot');
var PublicBallot = require('./public_ballot');

var votesUtils = require('./utils');

/**
 *
 * @type {module:dao_votes/ballot~Ballot}
 */
exports.Ballot = Ballot;

/**
 *
 * @type {module:dao_votes/public_ballot~PublicBallot}
 */
exports.PublicBallot = PublicBallot;

/**
 *
 * @type {module:dao_votes/utils}
 */
exports.utils = votesUtils;