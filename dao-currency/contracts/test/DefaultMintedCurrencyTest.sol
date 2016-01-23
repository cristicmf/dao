import "../../../dao-stl/src/assertions/DaoAsserter.sol";
import "../src/DefaultMintedCurrency.sol";
import "./MockCurrencyDatabase.sol";

contract DefaultMintedCurrencyTest is DaoAsserter {

    address constant TEST_ADDRESS = 0x12345;
    address constant TEST_ADDRESS_2 = 0x54321;

    uint constant TEST_AMOUNT = 30;

    uint16 constant MOCK_RETURN = 0x1111;

    function testCreateContract() {
        var dmc = new DefaultMintedCurrency(0, this);
        assertAddressesEqual(dmc.minter(), this, "minter returns the wrong address");
    }

    function testMintSuccess() {
        var mcd = new MockCurrencyDatabase();
        var dmc = new DefaultMintedCurrency(mcd, this);
        var err = dmc.mint(TEST_ADDRESS, TEST_AMOUNT);
        assertErrorsEqual(err, MOCK_RETURN, "mint returned the wrong error");
    }

    function testMintFailNotMinter() {
        var dmc = new DefaultMintedCurrency(0, TEST_ADDRESS);
        var err = dmc.mint(TEST_ADDRESS_2, TEST_AMOUNT);
        assertErrorsEqual(err, ACCESS_DENIED, "mint returned an error");
    }

    function testSetMinterSuccess() {
        var dmc = new DefaultMintedCurrency(0, this);
        var err = dmc.setMinter(TEST_ADDRESS_2);
        assertNoError(err, "setMinter returned error");
        var minter = dmc.minter();
        assertAddressesEqual(dmc.minter(), TEST_ADDRESS_2, "minter returns the wrong address");
    }

    function testSetMinterFailAccessDenied() {
        var dmc = new DefaultMintedCurrency(0, this);
        var err = dmc.setMinter(TEST_ADDRESS_2);
        assertNoError(err, "setMinter returned error");
        var minter = dmc.minter();
        assertAddressesEqual(dmc.minter(), TEST_ADDRESS_2, "minter returns the wrong address");
    }

}