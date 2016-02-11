var utils = require('./utils');

var path = require('path');

exports.registerRoutes = function(base_route, app, contracts){

    app.post(path.join(base_route, 'actions'), function(req, res){
        var contractId = req.body.contractId;
        var contractAddress = req.body.contractAddress;
        if(!contractId){
            res.status(400).send("'id' is missing from body.");
            return;
        }
        if(!contractAddress){
            res.status(400).send("'address' is missing from body.");
            return;
        }
        var from = req.header("Public-Address");
        contracts.doug().addContract(contractId, contractAddress, from, function(error, result){
            utils.txResp(res, error, result, "Failed to create contract");
        });
    });

    app.delete('/api/contracts/:id', function(req, res){
        var contractId = req.params.id;
        var from = req.header("Public-Address");
        contracts.doug().removeContract(contractId, from, function(error, result){
            utils.txResp(res, error, result, "Failed to delete contract");
        });
    });

    app.get('/api/contracts', function(req, res){
        console.log("getting contracts");
        var from = req.header("Public-Address");
        contracts.doug().contractAddresses(from, function(error, contracts){
            if(error){
                res.status(500).send('Failed to get contracts: ' + error.message);
            } else {
                res.status(200).send({contracts: contracts});
            }
        });
    });

    app.get('/api/contracts/:id', function(req, res){
        console.log("getting contract");
        var contractId = req.params.id;
        var from = req.header("Public-Address");
        contracts.doug().contractAddress(contractId, from, function(error, addr){
            if(error){
                res.status(500).send('Failed to get contract: ' + error.message);
            } else {
                res.status(200).send({contractId: contractId, contractAddress: addr});
            }
        });
    });
};