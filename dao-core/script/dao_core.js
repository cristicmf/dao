/**
 * @file dao_core.js
 * @fileOverview dao-core script.
 * @author Andreas Olofsson (androlo1980@gmail.com)
 * @module dao_core
 */
"use strict";

var load = require('./load');
var deploy = require('./deploy');

var Doug = require('./doug');
var Permission = require('./permission');

module.exports = {
    load: load,
    deploy: deploy,

    Doug: Doug,
    Permission: Permission
};