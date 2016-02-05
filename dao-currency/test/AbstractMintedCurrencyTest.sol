import "dao-stl/src/assertions/DaoTest.sol";
import "dao-currency/src/AbstractMintedCurrency.sol";

contract AbstractMintedCurrencyImpl is AbstractMintedCurrency {

    function AbstractMintedCurrencyImpl(address currencyDatabase, address minter)
        AbstractMintedCurrency(currencyDatabase, minter) {}

    function mint(address receiver, uint amount) returns (uint16 error) {}

    function send(address receiver, uint amount) returns (uint16 error) {}

    function send(address sender, address receiver, uint amount) returns (uint16 error) {}

}

contract AbstractMintedCurrencyTest is DaoTest {

    address constant TEST_ADDRESS = 0x12345;
    address constant TEST_ADDRESS_2 = 0x54321;

    function testSetMinterSuccess() {
        var amci = new AbstractMintedCurrencyImpl(0, this);

        amci.setMinter(TEST_ADDRESS).assertNoError("setMinter returned error");
        amci.minter().assertEqual(TEST_ADDRESS, "minter returns the wrong address");
    }

    function testSetMinterFailMinterNull() {
        var amci = new AbstractMintedCurrencyImpl(0, TEST_ADDRESS);

        amci.setMinter(0).assertErrorsEqual(NULL_PARAM_NOT_ALLOWED, "setMinter returned no 'null param' error");
        amci.minter().assertEqual(TEST_ADDRESS, "minter returns the wrong address");
    }

    function testSetMinterFailAccessDenied() {
        var amci = new AbstractMintedCurrencyImpl(0, TEST_ADDRESS);

        amci.setMinter(TEST_ADDRESS_2).assertErrorsEqual(ACCESS_DENIED, "setMinter returned no 'access denied' error");
        amci.minter().assertEqual(TEST_ADDRESS, "minter returns the wrong address");
    }

    function testSetCurrencyDatabaseSuccess() {
        var amci = new AbstractMintedCurrencyImpl(0, this);

        amci.setCurrencyDatabase(TEST_ADDRESS).assertNoError("setCurrencyDatabase returned an error");
        amci.currencyDatabase().assertEqual(TEST_ADDRESS, "currencyDatabase returns the wrong address");
    }

    function testSetCurrencyDatabaseFailNotMinter() {
        var amci = new AbstractMintedCurrencyImpl(TEST_ADDRESS, TEST_ADDRESS_2);

        amci.setCurrencyDatabase(this).assertErrorsEqual(ACCESS_DENIED, "setCurrencyDatabase did not return 'access denied' error");
        amci.currencyDatabase().assertEqual(TEST_ADDRESS, "currencyDatabase returns the wrong address");
    }



}