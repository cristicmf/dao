/**
 * @file dao_users.js
 * @fileOverview dao-users script.
 * @author Andreas Olofsson (androlo1980@gmail.com)
 * @module dao_users
 */
"use strict";

var UserDatabase = require('./user_database');
var UserRegistry = require('./user_registry');

/**
 *
 * @type {module:dao_users/user_database~UserDatabase}
 */
exports.UserDatabase = UserDatabase;

/**
 *
 * @type {module:dao_users/user_registry~UserRegistry}
 */
exports.UserRegistry = UserRegistry;