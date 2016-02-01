import "../src/currency/PublicMintingBallot.sol";

contract MockPublicCurrency {

    uint16 constant MPC_RETURN = 0x333;

    address _receiver;
    uint _amount;

    PublicMintingBallot _ballot;

    function createBallot(
        uint id,
        address userDatabase,
        address creator,
        uint opened,
        uint durationInSeconds,
        uint8 quorum,
        uint numEligibleVoters,
        address receiver,
        uint amount
    ) constant returns (address addr) {
        addr = new PublicMintingBallot(id, userDatabase, creator, opened, durationInSeconds,
            quorum, numEligibleVoters, receiver, amount);
        _ballot = PublicMintingBallot(addr);
    }

    function vote(address voter, uint8 vote, uint timestamp) returns (uint16 error) {
        return _ballot.vote(voter, vote, timestamp);
    }

    function mint(address receiver, uint amount) returns (uint16 error) {
        _receiver = receiver;
        _amount = amount;
        return MPC_RETURN;
    }

    function getData() constant returns (address receiver, uint amount) {
        return (_receiver, _amount);
    }

}