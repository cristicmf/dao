/**
 * @file utils.js
 * @fileOverview Utility functions for the voting module.
 * @author Andreas Olofsson (androlo1980@gmail.com)
 * @module dao_votes/utils
 */

/**
 * Get the name of a yes/no/abstain vote from its ordinal.
 *
 * 1 = 'Yes'
 * 2 = 'No'
 * 3 = 'Abstain'
 *
 * Everything else returns 'No Vote'.
 *
 * @param {number} ordinal - The ordinal.
 * @returns {string} The name.
 *
 * @alias module:dao_votes/utils.yesNoAbstainToName
 */
function yesNoAbstainToName(ordinal) {
    if (ordinal === 1) {
        return "Yes";
    } else if (ordinal === 2) {
        return "No";
    } else if (ordinal === 3) {
        return "Abstain";
    } else {
        return "No Vote";
    }
}

/**
 * Get the name of a ballot state from its ordinal.
 *
 * 0 = 'Null'
 * 1 = 'Open'
 * 2 = 'Closed'
 * 3 = 'Error'
 *
 * Everything else returns 'Unknown State'.
 *
 * @param {number} ordinal - The ordinal.
 * @returns {string} The name.
 *
 * @alias module:dao_votes/utils.stateToName
 */
function stateToName(ordinal) {
    if (ordinal === 0) {
        return "Null";
    } else if (ordinal === 1) {
        return "Open";
    } else if (ordinal === 2) {
        return "Closed";
    } else if (ordinal === 3) {
        return "Error";
    } else {
        return "Unknown State";
    }
}

exports.yesNoAbstainToName = yesNoAbstainToName;

exports.stateToName = stateToName;