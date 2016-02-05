import "dao-currency/src/CurrencyDatabase.sol";

contract MockCurrencyDatabase {

    uint16 constant MOCK_RETURN = 0x1111;

    address _mReceiver;
    address _sSender;
    address _sReceiver;

    uint _mAmount;
    uint _sAmount;

    function add(address receiver, int amount) returns (uint16 error) {
        _mReceiver = receiver;
        _mAmount = uint(amount);
        return MOCK_RETURN;
    }

    function send(address sender, address receiver, uint amount) returns (uint16 error){
        _sSender = sender;
        _sReceiver = receiver;
        _sAmount = amount;
        return MOCK_RETURN;
    }

    function accountBalance(address addr) constant returns (uint balance) {
        return 0;
    }

    function addData() constant returns (address receiver, uint amount) {
        return (_mReceiver, _mAmount);
    }

    function sendData() constant returns (address sender, address receiver, uint amount) {
        return (_sSender, _sReceiver, _sAmount);
    }
}