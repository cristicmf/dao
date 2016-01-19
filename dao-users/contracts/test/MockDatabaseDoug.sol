contract MockDatabaseDoug {

    bytes32 _id;

    function MockDatabaseDoug(bool isAction){
        if(isAction){
            _id = 0x1;
        }
    }

    function actionsContractId(address contractAddress) constant returns (bytes32 identifier){
        return _id;
    }

}