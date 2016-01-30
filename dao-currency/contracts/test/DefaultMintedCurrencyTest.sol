import "../../../dao-stl/contracts/src/assertions/DaoAsserter.sol";
import "./MockCurrencyDatabase.sol";
import "../src/DefaultMintedCurrency.sol";

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

    function testMintFailReceiverIsNull() {
        var mcd = new MockCurrencyDatabase();
        var dmc = new DefaultMintedCurrency(mcd, this);
        var err = dmc.mint(0, TEST_AMOUNT);
        assertErrorsEqual(err, NULL_PARAM_NOT_ALLOWED, "mint did not return 'null param' error");
    }

    function testMintFailAmountIsNull() {
        var mcd = new MockCurrencyDatabase();
        var dmc = new DefaultMintedCurrency(mcd, this);
        var err = dmc.mint(TEST_ADDRESS_2, 0);
        assertErrorsEqual(err, NULL_PARAM_NOT_ALLOWED, "mint did not return 'null param' error");
    }

    function testMintFailNotMinter() {
        var dmc = new DefaultMintedCurrency(0, TEST_ADDRESS);
        var err = dmc.mint(TEST_ADDRESS_2, TEST_AMOUNT);
        assertErrorsEqual(err, ACCESS_DENIED, "mint returned an error");
    }

    function testSendSuccess() {
        var mcd = new MockCurrencyDatabase();
        var dmc = new DefaultMintedCurrency(mcd, this);
        var err = dmc.send(TEST_ADDRESS, TEST_AMOUNT);
        assertErrorsEqual(err, MOCK_RETURN, "send returned the wrong error");
    }

    function testSendFailReceiverIsNull() {
        var mcd = new MockCurrencyDatabase();
        var dmc = new DefaultMintedCurrency(mcd, this);
        var err = dmc.send(0, TEST_AMOUNT);
        assertErrorsEqual(err, NULL_PARAM_NOT_ALLOWED, "send did not return 'null param' error");
    }

    function testSendFailAmountIsNull() {
        var mcd = new MockCurrencyDatabase();
        var dmc = new DefaultMintedCurrency(mcd, this);
        var err = dmc.send(TEST_ADDRESS, 0);
        assertErrorsEqual(err, NULL_PARAM_NOT_ALLOWED, "send did not return 'null param' error");
    }

    function testAdminSendSuccess() {
        var mcd = new MockCurrencyDatabase();
        var dmc = new DefaultMintedCurrency(mcd, this);
        var err = dmc.send(TEST_ADDRESS, TEST_ADDRESS_2, TEST_AMOUNT);
        assertErrorsEqual(err, MOCK_RETURN, "send returned the wrong error");
    }

    function testAdminSendFailNotAdmin() {
        var mcd = new MockCurrencyDatabase();
        var dmc = new DefaultMintedCurrency(mcd, TEST_ADDRESS);
        var err = dmc.send(this, TEST_ADDRESS_2, TEST_AMOUNT);
        assertErrorsEqual(err, ACCESS_DENIED, "send did not return 'access denied' error");
    }

    function testAdminSendFailSenderIsNull() {
        var mcd = new MockCurrencyDatabase();
        var dmc = new DefaultMintedCurrency(mcd, this);
        var err = dmc.send(0, TEST_ADDRESS, TEST_AMOUNT);
        assertErrorsEqual(err, NULL_PARAM_NOT_ALLOWED, "send did not return 'null param' error");
    }

    function testAdminSendFailReceiverIsNull() {
        var mcd = new MockCurrencyDatabase();
        var dmc = new DefaultMintedCurrency(mcd, this);
        var err = dmc.send(TEST_ADDRESS, 0, TEST_AMOUNT);
        assertErrorsEqual(err, NULL_PARAM_NOT_ALLOWED, "send did not return 'null param' error");
    }

    function testAdminSendFailAmountIsNull() {
        var mcd = new MockCurrencyDatabase();
        var dmc = new DefaultMintedCurrency(mcd, this);
        var err = dmc.send(TEST_ADDRESS, TEST_ADDRESS_2, 0);
        assertErrorsEqual(err, NULL_PARAM_NOT_ALLOWED, "send did not return 'null param' error");
    }

}