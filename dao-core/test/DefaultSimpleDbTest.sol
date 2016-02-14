import "./MockDatabaseDoug.sol";
import "./SimpleBase.sol";
import "dao-stl/src/assertions/DaoTest.sol";

contract DefaultSimpleDbTest is DaoTest {

    uint constant TEST_DATA = 55;

    function testSetSuccess() {
        var mdd = new MockDatabaseDoug(true);
        var dsdb = new DefaultSimpleDb();
        dsdb.setDougAddress(address(mdd));
        dsdb.setData(TEST_DATA).assertNoError("setData returned error");
        dsdb.data().assertEqual(TEST_DATA, "data returned the wrong value");
    }

    function testSetFail() {
        var mdd = new MockDatabaseDoug(false);
        var dsdb = new DefaultSimpleDb();
        dsdb.setDougAddress(address(mdd));
        dsdb.setData(TEST_DATA).assertErrorsEqual(ACCESS_DENIED, "setData returned error");
        dsdb.data().assertZero("data returned the wrong value");
    }

}