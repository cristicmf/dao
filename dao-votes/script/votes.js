exports.voteNumToName = function (number) {
    if (number === 1) {
        return "Yes";
    } else if (number === 2) {
        return "No";
    } else if (number === 3) {
        return "Abstain";
    } else {
        return "No vote";
    }
};

exports.voteNameToNum = function (name) {
    if (name === "Yes") {
        return 1;
    } else if (name === "No") {
        return 2;
    } else if (name === "Abstain") {
        return 3;
    } else {
        return 0;
    }
};