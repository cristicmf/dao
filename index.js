/**
 * @file index.js
 * @fileOverview dao script.
 * @author Andreas Olofsson (androlo1980@gmail.com)
 * @module index
 */
var errors = require('./script/errors');
var daoUtils = require('./script/dao_utils');
var Deployer = require('./script/deployer');
var builder = require('./script/builder');
var compile = require('./script/solc');
var ContractService = require('./script/contract_service');

var daoCore = require('./dao-core/script/dao_core');
var daoCurrency = require('./dao-currency/script/dao_currency');
var daoUsers = require('./dao-users/script/dao_users');
var daoVotes = require('./dao-votes/script/dao_votes');

/**
 * Errors.
 *
 * @type {module:errors}
 */
exports.errors = errors;

/**
 * Utilities.
 *
 * @type {module:dao_utils}
 */
exports.utils = daoUtils;

/**
 * Builder.
 *
 * @type {module:builder}
 */
exports.builder = builder;

/**
 * Javascript binding for 'solc'.
 *
 * @type {module:solc}
 */
exports.compile = compile;

/**
 *
 * @type {module:deployer~Deployer}
 */
exports.Deployer = Deployer;

/**
 *
 * @type {module:contract_service~ContractService}
 */
exports.ContractService = ContractService;

/**
 * Dao-core.
 *
 * @type {module:dao_core}
 */
exports.core = daoCore;

/**
 * Dao-currency.
 *
 * @type {module:dao_currency}
 */
exports.users = daoCurrency;

/**
 * Dao-users.
 *
 * @type {module:dao_users}
 */
exports.users = daoUsers;

/**
 * Dao-votes.
 *
 * @type {module:dao_votes}
 */
exports.votes = daoVotes;