/**
 * @file dao_currency.js
 * @fileOverview dao-users script.
 * @author Andreas Olofsson (androlo1980@gmail.com)
 * @module dao_currency
 */
"use strict";

var CurrencyDatabase = require('./currency_database');
var MintedCurrency = require('./minted_currency');

/**
 *
 * @type {module:dao_currency/currency_database~CurrencyDatabase}
 */
exports.CurrencyDatabase = CurrencyDatabase;

/**
 *
 * @type {module:dao_currency/minted_currency~MintedCurrency}
 */
exports.MintedCurrency = MintedCurrency;