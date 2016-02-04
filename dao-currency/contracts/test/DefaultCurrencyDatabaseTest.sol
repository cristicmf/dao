import "../../../dao-stl/contracts/src/assertions/DaoTest.sol";
import "../../../dao-core/contracts/test/MockDatabaseDoug.sol";
import "../src/DefaultCurrencyDatabase.sol";

contract DefaultCurrencyDatabaseTest is DaoTest {

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

        cdb.add(TEST_ADDRESS, TEST_ADD_AMOUNT).assertNoError("add returned error");
        cdb.accountBalance(TEST_ADDRESS).assertEqual(uint(TEST_ADD_AMOUNT), "accountBalance returns the wrong balance.");
    }

    function testAddFailNotActions(){
        var mdd = new MockDatabaseDoug(false);
        var cdb = new DefaultCurrencyDatabase();
        cdb.setDougAddress(address(mdd));

        cdb.add(TEST_ADDRESS, TEST_ADD_AMOUNT).assertErrorsEqual(ACCESS_DENIED, "add returned no 'access denied' error");
        cdb.accountBalance(TEST_ADDRESS).assertZero("accountBalance is not 0.");
    }

    function testAddFailRemoveMoreThenCurrentBalance(){
        var mdd = new MockDatabaseDoug(true);
        var cdb = new DefaultCurrencyDatabase();
        cdb.setDougAddress(address(mdd));

        cdb.add(TEST_ADDRESS, TEST_ADD_AMOUNT_NEG).assertErrorsEqual(TRANSFER_FAILED, "add returned no 'transfer failed' error");
        cdb.accountBalance(TEST_ADDRESS).assertZero("accountBalance is not 0.");
    }

    function testSendSuccess(){
        var mdd = new MockDatabaseDoug(true);
        var cdb = new DefaultCurrencyDatabase();
        cdb.setDougAddress(address(mdd));

        cdb.add(TEST_ADDRESS, TEST_ADD_AMOUNT).assertNoError("add returned error");
        cdb.send(TEST_ADDRESS, TEST_ADDRESS_2, TEST_SEND_AMOUNT).assertNoError("send returned error");
        cdb.accountBalance(TEST_ADDRESS).assertEqual(uint(TEST_ADD_AMOUNT) - TEST_SEND_AMOUNT,
            "accountBalance returns the wrong balance for sender.");
        cdb.accountBalance(TEST_ADDRESS_2).assertEqual(uint(TEST_SEND_AMOUNT), "accountBalance returns the wrong balance for receiver.");
    }

    function testSendFailNotActions(){
        var mdd = new MockDatabaseDoug(false);
        var cdb = new DefaultCurrencyDatabase();
        cdb.setDougAddress(address(mdd));

        cdb.send(TEST_ADDRESS, TEST_ADDRESS_2, TEST_SEND_AMOUNT).assertErrorsEqual(ACCESS_DENIED, "send returned no 'access denied' error");
        cdb.accountBalance(TEST_ADDRESS).assertZero("accountBalance is not 0.");
    }

    function testSendFailNotEnoughFunds(){
        var mdd = new MockDatabaseDoug(true);
        var cdb = new DefaultCurrencyDatabase();
        cdb.setDougAddress(address(mdd));

        cdb.send(TEST_ADDRESS, TEST_ADDRESS_2, TEST_SEND_AMOUNT).assertErrorsEqual(INSUFFICIENT_SENDER_BALANCE,
            "send returned no 'insufficient sender balance' error");

        cdb.accountBalance(TEST_ADDRESS_2).assertZero("accountBalance is not 0 for receiver.");
    }



}