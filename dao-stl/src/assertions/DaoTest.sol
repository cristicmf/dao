/*
    File: DaoTest.sol
    Author: Andreas Olofsson (androlo1980@gmail.com)
*/
import "./Assertions.sol";
import "../errors/Errors.sol";

/*
    Contract: DaoTest

    Contract that binds all valid types to the <Assertions> methods. It also extends <Errors>.
*/
contract DaoTest is Errors {
    using Assertions for bool;
    using Assertions for bytes32;
    using Assertions for string;
    using Assertions for address;
    using Assertions for int;
    using Assertions for uint;
    using Assertions for uint16;
}