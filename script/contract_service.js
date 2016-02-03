
function ContractService(web3, contract, gas) {
    this._web3 = web3;
    this._contract = contract;
    this._gas = gas;
}

// Waits for event to trigger or 2 minutes passes. Returns 'eventData.args'.
ContractService.prototype.waitForArgs = function(eventName, txHash, cb){
    var event;

    try {
        event = this._contract[eventName]();
    } catch (error) {
        return cb(error);
    }

    event.watch(function(error, data){
        if (error) return cb(error);
        if(txHash === data.transactionHash) {
            if (timeout) clearTimeout(timeout);
            event.stopWatching();
            cb(null, data.args);
        }
    });

    var timeout = setTimeout(function(){
        event.stopWatching();
        return cb(new Error("Timed out waiting for event"));
    } , 120000);
};

//  Waits for event to trigger or 2 minutes passes. Returns 'eventData.args.error'.
ContractService.prototype.waitFor = function(eventName, txHash, cb){
    var event;

    try {
        event = this._contract[eventName]();
    } catch (error) {
        return cb(error);
    }

    event.watch(function(error, data){
        if (error) return cb(error);
        if(txHash === data.transactionHash) {
            if (timeout) clearTimeout(timeout);
            event.stopWatching();
            cb(null, data.args.error.toNumber());
        }
    });

    var timeout = setTimeout(function(){
        event.stopWatching();
        return cb(new Error("Timed out waiting for event"));
    } , 120000);
};

//  Waits for event to trigger or 2 minutes passes. Returns 'eventData.args.error'.
ContractService.prototype.waitForDestroyed = function(txHash, cb){
    var event;

    try {
        event = this._contract.Destroy();
    } catch (error) {
        return cb(error);
    }
    var that = this;
    event.watch(function(error, data){
        if (error) return cb(error);
        if(txHash === data.transactionHash) {
            if (timeout) clearTimeout(timeout);
            event.stopWatching();
            var code = data.args.error.toNumber();
            if (code !== 0) {
                return cb(null, code);
            }
            that._web3.eth.getCode(that._contract.address, function(error, code){
                if(error) return cb(error);
                if (code !== "0x") {
                    return cb(new Error("Account not destroyed after contract destroy event was fired."));
                }
                cb(null, 0);
            });
        }
    });

    var timeout = setTimeout(function(){
        event.stopWatching();
        return cb(new Error("Timed out waiting for event"));
    } , 120000);
};

ContractService.prototype.contract = function() {
    return this._contract;
};

ContractService.prototype.address = function() {
    return this._contract.address;
};

ContractService.prototype.web3 = function() {
    return this._web3;
};

module.exports = ContractService;