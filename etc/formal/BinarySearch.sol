
contract BinarySearch {

  ///@why3
  /// requires { arg_data.length < UInt256.max_uint256 }
  /// requires { 0 <= to_int arg_begin <= to_int arg_end <= arg_data.length }
  /// requires { forall i j: int. 0 <= i <= j < arg_data.length -> to_int arg_data[i] <= to_int arg_data[j] }
  /// variant { to_int arg_end - to_int arg_begin }
  /// ensures {
  ///   to_int result < UInt256.max_uint256 -> (to_int arg_begin <= to_int result < to_int arg_end && to_int arg_data[to_int result] = to_int arg_value)
  /// }
  /// ensures {
  ///   to_int result = UInt256.max_uint256 -> (forall i: int. to_int arg_begin <= i < to_int arg_end -> to_int arg_data[i] <> to_int arg_value)
  /// }
  function find_internal(uint[] data, uint begin, uint end, uint value) internal returns (uint ret) {
    uint len = end - begin;
    if (len == 0 || (len == 1 && data[begin] != value)) {
      return 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    }
    uint mid = begin + len / 2;
    uint v = data[mid];
    if (value < v)
      return find_internal(data, begin, mid, value);
    else if (value > v)
      return find_internal(data, mid + 1, end, value);
    else
      return mid;
  }

  ///@why3
  /// requires { arg_data.length < UInt256.max_uint256 }
  /// requires { forall i j: int. 0 <= i <= j < arg_data.length -> to_int arg_data[i] <= to_int arg_data[j] }
  /// ensures {
  ///   to_int result < UInt256.max_uint256 -> to_int arg_data[to_int result] = to_int arg_value
  /// }
  /// ensures {
  ///   to_int result = UInt256.max_uint256 -> forall i: int. 0 <= i < arg_data.length -> to_int arg_data[i] <> to_int arg_value
  /// }
  function find(uint[] data, uint value) returns (uint ret) {
    return find_internal(data, 0, data.length, value);
  }
}