import "../../../dao-users/contracts/src/UserDatabase.sol";

contract MockUserDatabase is UserDatabase {

    uint16 constant MOCK_RETURN = 0x1111;

    uint _joined;
    uint _size;
    bool _has;

    function MockUserDatabase(uint joined, bool has, uint size) {
        _joined = joined;
        _has = has;
        _size = size;
    }

    function registerUser(address addr, bytes32 value_nickname, uint value_timestamp, bytes32 value_dataHash) returns (uint16 error) {
        return MOCK_RETURN;
    }

    function updateDataHash(address addr, bytes32 dataHash) returns (uint16 error) {
        return MOCK_RETURN;
    }

    function removeUser(address addr) returns (uint16 error) {
        return MOCK_RETURN;
    }

    function user(address addr) constant returns (bytes32 value_nickname, uint value_timestamp, bytes32 value_dataHash) {
        value_timestamp = _joined;
    }

    function user(bytes32 nickname) constant returns (bytes32 value_nickname, uint value_timestamp, bytes32 value_dataHash) {
        value_timestamp = _joined;
    }

    function hasUser(address addr) constant returns (bool has) {
        return _has;
    }

    function hasUser(bytes32 nickname) constant returns (bool has) {
        return _has;
    }

    function hasUsers(address addr1, address addr2) constant returns (bool has1, bool has2) {
        has1 = _has;
        has2 = _has;
    }

    function hasUsers(bytes32 nickname1, bytes32 nickname2) constant returns (bool has1, bool has2) {
        has1 = _has;
        has2 = _has;
    }

    function userAddressFromIndex(uint index) constant returns (address addr, uint16 error) {}

    function size() constant returns (uint size) {
        return _size;
    }

    function setDougAddress(address dougAddr) returns (address result) {}

    function dougAddress() constant returns (address dougAddress) {
        return MOCK_RETURN;
    }

    function destroy(address fundReceiver) {}

    function _checkCaller() constant internal returns (bool) {}

}