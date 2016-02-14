import "./MockDatabaseDoug.sol";
import "./SimpleBase.sol";
import "dao-stl/src/assertions/DaoTest.sol";

contract SimpleOneTest is DaoTest {

    uint constant TEST_DATA = 55;

    function testAddSuccess() {
        var dp = new DefaultPermission(this);
        var dd = new DefaultDoug(dp, false, false);

        var dsdb = new DefaultSimpleDb();
        var so = new SimpleOne(dsdb);
        dd.addActionsContract("simple", so);

        so.addData(TEST_DATA).assertNoError("addData returned an error");
    }

    function testAddFailNotActions() {
        var mdd = new MockDatabaseDoug(false);
        var dsdb = new DefaultSimpleDb();
        var so = new SimpleOne(dsdb);
        dsdb.setDougAddress(mdd);
        so.addData(TEST_DATA).assertErrorsEqual(ACCESS_DENIED, "addData returned no 'access denied' error");
    }

}