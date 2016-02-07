import "./MockDatabaseDoug.sol";
import "dao-core/src/Database.sol";
import "dao-core/src/DefaultDoug.sol";
import "dao-core/src/DefaultPermission.sol";
import "dao-stl/src/assertions/DaoTest.sol";
import "dao-stl/src/errors/Errors.sol";

contract SimpleDb is Database {
    function setData(uint data) returns (uint16 error);
    function data() constant returns (uint data);
}


contract DefaultSimpleDb is SimpleDb, DefaultDatabase {

    uint _data;

    function setData(uint data) returns (uint16 error) {
        if (!_checkCaller())
            error = ACCESS_DENIED;
        else
            _data = data;
    }

    function data() constant returns (uint data) {
        return _data;
    }

}


contract AbstractSimple is DefaultDougEnabled  {

    event AddData(uint indexed data, uint16 error);

    SimpleDb _simpleDb;

    function AbstractSimple(address simpleDb) {
        _simpleDb = SimpleDb(simpleDb);
    }

    function addData(uint data) returns (uint16 error);

}


contract SimpleOne is AbstractSimple {

    function SimpleOne(address simpleDb) AbstractSimple(simpleDb) {}

    function addData(uint data) returns (uint16 error) {
        error = _simpleDb.setData(data);
        AddData(data, error);
    }

}


contract SimpleTwo is AbstractSimple {

    address _owner;

    function SimpleTwo(address simpleDb, address owner) AbstractSimple(simpleDb) {
        _owner = owner;
    }

    function addData(uint data) returns (uint16 error) {
        if (msg.sender != _owner)
            error = ACCESS_DENIED;
        else
            error = _simpleDb.setData(data);
        AddData(data, error);
    }

}


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