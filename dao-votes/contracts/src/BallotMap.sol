/*
    Contract: BallotMap

    A basic map for ballot-contracts (address -> bytes32). Should be extended.

    Author: Andreas Olofsson (androlo1980@gmail.com)
*/
contract BallotMap {

    /*
        Struct: Element

        Element type for the map.
        Members should not be accessed directly.

        Members:

        _valIndex - The index of the value in the backing array.
        value - The value.

    */
    struct Element {
        uint _keyIndex;
        bytes32 value;
    }

    /*
        Struct: Map

        Contains mappings of 'address' -> <Element>, and an array with all keys for iteration.
    */
    struct Map
    {
        mapping(address => Element) _data;
        address[] _keys;
    }

    Map _ballotMap;

    /*
        Function: _insert

        Called to cast a vote.

        Params:
            key (address) - A ballot-contract address.
            value (bytes32) - A value. Usually the ballot type.

        Returns:
            added (bool) - Whether or not the ballot was added.
    */
    function _insert(address key, bytes32 value) internal returns (bool added) {
        _ballotMap._data[key] = Element(_ballotMap._keys.push(key) - 1, value);
        return true;
    }

    /*
        Function: _remove

        Called to remove a vote from the map.

        Params:
            key (address) - A ballot-contract address.

        Returns:
            value (bytes32) - The value mapped to the removed key, if any.
            removed (bool) - Whether or not the ballot was removed.
    */
    function _remove(address key) internal returns (bytes32 value, bool removed) {
        var elem = _ballotMap._data[key];
        value = elem.value;
        var exists = value != 0;
        if (!exists)
            return;
        var keyIndex = elem._keyIndex;

        delete _ballotMap._data[key];
        var len = _ballotMap._keys.length;
        if (keyIndex != len - 1) {
            var swap = _ballotMap._keys[len - 1];
            _ballotMap._keys[keyIndex] = swap;
            _ballotMap._data[swap]._keyIndex = keyIndex;
        }
        _ballotMap._keys.length--;
        removed = true;
    }

    /*
        Function: ballot

        Called to get a ballot value.

        Params:
            key (address) - A ballot-contract address.

        Returns:
            value (bytes32) - The value mapped to the removed key, if any.
    */
    function ballot(address key) constant returns(bytes32 value) {
        return _ballotMap._data[key].value;
    }

    /*
        Function: ballotFromIndex

        Called to get a ballot from its index in the backing array.

        Params:
            index (uint) - The index.

        Returns:
            key (address) - The address of the ballot-contract.
            value (bytes32) - The removed value.
            exists (bool) - 'false' if the index is out of bounds.
    */
    function ballotFromIndex(uint index) constant returns (address key, bytes32 value, bool exists) {
        if (index >= _ballotMap._keys.length)
            return;
        key = _ballotMap._keys[index];
        value = _ballotMap._data[key].value;
        exists = true;
    }

    /*
        Function: numBallots

        Called to get the number of ballots in the map.

        Returns:
            numBallots (uint) - The number of ballots in the map.
    */
    function numBallots() constant returns (uint numBallots) {
        return _ballotMap._keys.length;
    }

}