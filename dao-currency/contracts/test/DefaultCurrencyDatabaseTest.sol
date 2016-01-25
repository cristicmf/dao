import "../../../dao-stl/src/assertions/DaoAsserter.sol";
import "../../../dao-core/contracts/test/MockDatabaseDoug.sol";
import "../src/DefaultCurrencyDatabase.sol";

contract DefaultCurrencyDatabaseTest is DaoAsserter {

    address constant TEST_ADDRESS = 0x12345;
    address constant TEST_ADDRESS_2 = 0x54321;

    int constant TEST_ADD_AMOUNT = 55;
    int constant TEST_ADD_AMOUNT_2 = 60;
    int constant TEST_ADD_AMOUNT_NEG = -50;

    uint constant TEST_SEND_AMOUNT = 30;

    function testAddSuccess(){
        var mdd = new MockDatabaseDoug(true);
        var cdb = new DefaultCurrencyDatabase();
        cdb.setDougAddress(address(mdd));

        var err = cdb.add(TEST_ADDRESS, TEST_ADD_AMOUNT);
        assertNoError(err, "add returned error");

        var ab = cdb.accountBalance(TEST_ADDRESS);
        assertUintsEqual(ab, uint(TEST_ADD_AMOUNT), "accountBalance returns the wrong balance.");
    }

    function testAddFailNotActions(){
        var mdd = new MockDatabaseDoug(false);
        var cdb = new DefaultCurrencyDatabase();
        cdb.setDougAddress(address(mdd));

        var err = cdb.add(TEST_ADDRESS, TEST_ADD_AMOUNT);
        assertErrorsEqual(err, ACCESS_DENIED, "add returned no 'access denied' error");

        var ab = cdb.accountBalance(TEST_ADDRESS);
        assertUintZero(ab, "accountBalance is not 0.");
    }

    function testAddFailRemoveMoreThenCurrentBalance(){
        var mdd = new MockDatabaseDoug(true);
        var cdb = new DefaultCurrencyDatabase();
        cdb.setDougAddress(address(mdd));

        var err = cdb.add(TEST_ADDRESS, TEST_ADD_AMOUNT_NEG);
        assertErrorsEqual(err, TRANSFER_FAILED, "add returned no 'transfer failed' error");

        var ab = cdb.accountBalance(TEST_ADDRESS);
        assertUintZero(ab, "accountBalance is not 0.");
    }

    function testSendSuccess(){
        var mdd = new MockDatabaseDoug(true);
        var cdb = new DefaultCurrencyDatabase();
        cdb.setDougAddress(address(mdd));

        var err = cdb.add(TEST_ADDRESS, TEST_ADD_AMOUNT);
        assertNoError(err, "add returned error");

        err = cdb.send(TEST_ADDRESS, TEST_ADDRESS_2, TEST_SEND_AMOUNT);
        assertNoError(err, "send returned error");

        var ab = cdb.accountBalance(TEST_ADDRESS);
        assertUintsEqual(ab, uint(TEST_ADD_AMOUNT) - TEST_SEND_AMOUNT, "accountBalance returns the wrong balance for sender.");

        ab = cdb.accountBalance(TEST_ADDRESS_2);
        assertUintsEqual(ab, uint(TEST_SEND_AMOUNT), "accountBalance returns the wrong balance for receiver.");
    }

    function testSendFailNotActions(){
        var mdd = new MockDatabaseDoug(false);
        var cdb = new DefaultCurrencyDatabase();
        cdb.setDougAddress(address(mdd));

        var err = cdb.send(TEST_ADDRESS, TEST_ADDRESS_2, TEST_SEND_AMOUNT);
        assertErrorsEqual(err, ACCESS_DENIED, "send returned no 'access denied' error");

        var ab = cdb.accountBalance(TEST_ADDRESS);
        assertUintZero(ab, "accountBalance is not 0.");
    }

    function testSendFailNotEnoughFunds(){
        var mdd = new MockDatabaseDoug(true);
        var cdb = new DefaultCurrencyDatabase();
        cdb.setDougAddress(address(mdd));

        var err = cdb.send(TEST_ADDRESS, TEST_ADDRESS_2, TEST_SEND_AMOUNT);
        assertErrorsEqual(err, INSUFFICIENT_SENDER_BALANCE, "send returned no 'insufficient sender balance' error");

        var ab = cdb.accountBalance(TEST_ADDRESS_2);
        assertUintZero(ab, "accountBalance is not 0 for receiver.");
    }



}