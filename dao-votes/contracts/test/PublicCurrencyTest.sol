import "../../../dao-stl/src/assertions/DaoTest.sol";
import "../src/currency/PublicCurrency.sol";
import "../../../dao-users/contracts/test/MockUserDatabase.sol";
import "../../../dao-currency/contracts/test/MockCurrencyDatabase.sol";

contract PublicCurrencyTest is DaoTest {

    address constant TEST_ADDRESS = 0x12345;
    address constant TEST_ADDRESS_2 = 0x54321;

    function testCreate() {
        var pc = new PublicCurrency(TEST_ADDRESS, TEST_ADDRESS_2, false);

    }
}