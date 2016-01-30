import "../../../dao-stl/contracts/src/assertions/DaoAsserter.sol";
import "../../../dao-users/contracts/test/MockUserDatabase.sol";
import "../src/MintedUserCurrency.sol";
import "./MockCurrencyDatabase.sol";

contract MintedUserCurrencyTest is DaoAsserter {

    address constant TEST_ADDRESS = 0x12345;
    address constant TEST_ADDRESS_2 = 0x54321;

    uint constant TEST_AMOUNT = 30;

    uint16 constant MOCK_RETURN = 0x1111;

    function testCreateContract() {
        var muc = new MintedUserCurrency(0, 0, this);
        assertAddressesEqual(muc.minter(), this, "minter returns the wrong address");
    }

    function testMintSuccess() {
        var mcd = new MockCurrencyDatabase();
        var mud = new MockUserDatabase(0, true, 0);
        var muc = new MintedUserCurrency(mcd, mud, this);
        var err = muc.mint(TEST_ADDRESS, TEST_AMOUNT);
        assertErrorsEqual(err, MOCK_RETURN, "mint returned the wrong error");
    }

    function testMintFailReceiverIsNull() {
        var mcd = new MockCurrencyDatabase();
        var mud = new MockUserDatabase(0, true, 0);
        var muc = new MintedUserCurrency(mcd, mud, this);
        var err = muc.mint(0, TEST_AMOUNT);
        assertErrorsEqual(err, NULL_PARAM_NOT_ALLOWED, "mint did not return 'null param' error");
    }

    function testMintFailAmountIsNull() {
        var mcd = new MockCurrencyDatabase();
        var mud = new MockUserDatabase(0, true, 0);
        var muc = new MintedUserCurrency(mcd, mud, this);
        var err = muc.mint(TEST_ADDRESS_2, 0);
        assertErrorsEqual(err, NULL_PARAM_NOT_ALLOWED, "mint did not return 'null param' error");
    }

    function testMintFailNotMinter() {
        var muc = new MintedUserCurrency(0, 0, TEST_ADDRESS);
        var err = muc.mint(TEST_ADDRESS_2, TEST_AMOUNT);
        assertErrorsEqual(err, ACCESS_DENIED, "mint did not return 'access denied' error");
    }

    function testMintFailReceiverNotUser() {
        var mcd = new MockCurrencyDatabase();
        var mud = new MockUserDatabase(0, false, 0);
        var muc = new MintedUserCurrency(mcd, mud, this);
        var err = muc.mint(TEST_ADDRESS, TEST_AMOUNT);
        assertErrorsEqual(err, RESOURCE_NOT_FOUND, "mint did not return 'resource not found' error");
    }

    function testSendSuccess() {
        var mcd = new MockCurrencyDatabase();
        var mud = new MockUserDatabase(0, true, 0);
        var muc = new MintedUserCurrency(mcd, mud, this);
        var err = muc.send(TEST_ADDRESS, TEST_AMOUNT);
        assertErrorsEqual(err, MOCK_RETURN, "mint returned the wrong error");
    }

    function testSendFailReceiverIsNull() {
        var mcd = new MockCurrencyDatabase();
        var mud = new MockUserDatabase(0, true, 0);
        var muc = new MintedUserCurrency(mcd, mud, this);
        var err = muc.send(0, TEST_AMOUNT);
        assertErrorsEqual(err, NULL_PARAM_NOT_ALLOWED, "mint did not return 'null param' error");
    }

    function testSendFailAmountIsNull() {
        var mcd = new MockCurrencyDatabase();
        var mud = new MockUserDatabase(0, true, 0);
        var muc = new MintedUserCurrency(mcd, mud, this);
        var err = muc.send(TEST_ADDRESS, 0);
        assertErrorsEqual(err, NULL_PARAM_NOT_ALLOWED, "mint did not return 'null param' error");
    }

    function testSendFailSenderAndReceiverNotUsers() {
        var mcd = new MockCurrencyDatabase();
        var mud = new MockUserDatabase(0, false, 0);
        var muc = new MintedUserCurrency(mcd, mud, this);
        var err = muc.send(TEST_ADDRESS, TEST_AMOUNT);
        assertErrorsEqual(err, RESOURCE_NOT_FOUND, "mint did not return 'resource not found' error");
    }

    function testAdminSendSuccess() {
        var mcd = new MockCurrencyDatabase();
        var mud = new MockUserDatabase(0, true, 0);
        var muc = new MintedUserCurrency(mcd, mud, this);
        var err = muc.send(TEST_ADDRESS, TEST_ADDRESS_2, TEST_AMOUNT);
        assertErrorsEqual(err, MOCK_RETURN, "send returned the wrong error");
    }

    function testAdminSendFailNotAdmin() {
        var mcd = new MockCurrencyDatabase();
        var mud = new MockUserDatabase(0, true, 0);
        var muc = new MintedUserCurrency(mcd, mud,TEST_ADDRESS);
        var err = muc.send(this, TEST_ADDRESS_2, TEST_AMOUNT);
        assertErrorsEqual(err, ACCESS_DENIED, "send did not return 'access denied' error");
    }

    function testAdminSendFailSenderIsNull() {
        var mcd = new MockCurrencyDatabase();
        var mud = new MockUserDatabase(0, true, 0);
        var muc = new MintedUserCurrency(mcd, mud, this);
        var err = muc.send(0, TEST_ADDRESS, TEST_AMOUNT);
        assertErrorsEqual(err, NULL_PARAM_NOT_ALLOWED, "send did not return 'null param' error");
    }

    function testAdminSendFailReceiverIsNull() {
        var mcd = new MockCurrencyDatabase();
        var mud = new MockUserDatabase(0, true, 0);
        var muc = new MintedUserCurrency(mcd, mud, this);
        var err = muc.send(TEST_ADDRESS, 0, TEST_AMOUNT);
        assertErrorsEqual(err, NULL_PARAM_NOT_ALLOWED, "send did not return 'null param' error");
    }

    function testAdminSendFailAmountIsNull() {
        var mcd = new MockCurrencyDatabase();
        var mud = new MockUserDatabase(0, true, 0);
        var muc = new MintedUserCurrency(mcd, mud, this);
        var err = muc.send(TEST_ADDRESS, TEST_ADDRESS_2, 0);
        assertErrorsEqual(err, NULL_PARAM_NOT_ALLOWED, "send did not return 'null param' error");
    }

    function testAdminSendFailSenderAndReceiverNotUsers() {
        var mcd = new MockCurrencyDatabase();
        var mud = new MockUserDatabase(0, false, 0);
        var muc = new MintedUserCurrency(mcd, mud, this);
        var err = muc.send(TEST_ADDRESS, TEST_ADDRESS_2, TEST_AMOUNT);
        assertErrorsEqual(err, RESOURCE_NOT_FOUND, "mint did not return 'resource not found' error");
    }

}