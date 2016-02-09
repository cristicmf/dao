/**
 * @file index.js
 * @fileOverview dao script.
 * @author Andreas Olofsson (androlo1980@gmail.com)
 * @module index
 */
var errors = require('./script/errors');
var daoUtils = require('./script/dao_utils');
var Deployer = require('./script/deployer');
var ContractService = require('./script/contract_service');

var daoCore = require('./dao-core/script/dao_core');
var daoUsers = require('./dao-users/script/dao_users');

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
 * Dao-users.
 *
 * @type {module:dao_users}
 */
exports.users = daoUsers;