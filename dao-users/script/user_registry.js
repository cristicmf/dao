/**
 * @file user_registry.js
 * @fileOverview Contract service for 'UserRegistry'.
 * @author Andreas Olofsson (androlo1980@gmail.com)
 * @module dao_users/user_registry
 */
"use strict";

var util = require('util');

var ContractService = require('../../script/contract_service');
var daoUtils = require('../../script/dao_utils');

/**
 * Service for 'UserRegistry'
 *
 * @param {Object} web3 - A web3 object.
 * @param {Object} contract - A web3 contract instance.
 * @param {number} gas - The amount of gas that will be used in transactions.
 *
 * @constructor
 * @augments module:contract_service:ContractService
 */
function UserRegistry(web3, contract, gas) {
    ContractService.call(this, web3, contract, gas);
}

util.inherits(UserRegistry, ContractService);

