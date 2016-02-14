import "./MockDatabaseDoug.sol";
import "./SimpleBase.sol";
import "dao-stl/src/assertions/DaoTest.sol";

contract SimpleTwoTest is DaoTest {

    uint constant TEST_DATA = 55;

    function testAddSuccess() {
        var dp = new DefaultPermission(this);
        var dd = new DefaultDoug(dp, false, false);

        var dsdb = new DefaultSimpleDb();
        var st = new SimpleTwo(dsdb, this);
        dd.addActionsContract("simple", st);

        st.addData(TEST_DATA).assertNoError("addData returned an error");
    }

    function testAddFailNotActions() {
        var mdd = new MockDatabaseDoug(false);
        var dsdb = new DefaultSimpleDb();
        var st = new SimpleTwo(dsdb, this);
        dsdb.setDougAddress(mdd);
        st.addData(TEST_DATA).assertErrorsEqual(ACCESS_DENIED, "addData returned no 'access denied' error");
    }

    function testAddFailNotOwner() {
        var dp = new DefaultPermission(this);
        var dd = new DefaultDoug(dp, false, false);

        var dsdb = new DefaultSimpleDb();
        var st = new SimpleTwo(dsdb, 0);
        dd.addActionsContract("simple", st);

        st.addData(TEST_DATA).assertErrorsEqual(ACCESS_DENIED, "addData returned no 'access denied' error");
    }

}