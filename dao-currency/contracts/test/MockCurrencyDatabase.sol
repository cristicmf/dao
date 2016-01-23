import "../src/CurrencyDatabase.sol";

contract MockCurrencyDatabase {

    uint16 constant MOCK_RETURN = 0x1111;

    function add(address receiver, int amount) returns (uint16 error) {
        return MOCK_RETURN;
    }

    function send(address sender, address receiver, uint amount) returns (uint16 error){
        return MOCK_RETURN;
    }

    function accountBalance(address addr) constant returns (uint balance) {
        return 0;
    }
}