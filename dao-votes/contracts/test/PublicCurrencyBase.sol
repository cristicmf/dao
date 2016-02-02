import "../../../dao-stl/contracts/src/assertions/DaoTest.sol";

contract PublicCurrencyBase is DaoTest {

    uint    constant TEST_ID                    = 1;
    uint    constant TEST_ID_2                  = 2;
    uint    constant TEST_DURATION              = 1 days;
    uint8   constant TEST_QUORUM                = 50;
    uint    constant TEST_KEEP_DURATION         = 1 years;
    uint    constant TEST_NUM_ELIGIBLE_VOTERS   = 1;
    uint16  constant MCD_RETURN                 = 0x1111;
    address constant TEST_ADDRESS               = 0x12345;
    address constant TEST_ADDRESS_2             = 0x54321;

}