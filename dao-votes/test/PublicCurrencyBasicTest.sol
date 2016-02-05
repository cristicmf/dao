import "./PublicCurrencyBase.sol";
import "dao-votes/src/currency/PublicCurrency.sol";

contract PublicCurrencyBasicTest is PublicCurrencyBase {

    function testCreate() {
        var pc = new PublicCurrency(TEST_ADDRESS, TEST_ADDRESS_2);
        pc.currencyDatabase().assertEqual(TEST_ADDRESS, "currency database address not correct");
        pc.userDatabase().assertEqual(TEST_ADDRESS_2, "user database address not correct");
        pc.minter().assertEqual(pc, "minter returns wrong address");
        pc.duration().assertEqual(TEST_DURATION, "duration is wrong");
        uint(pc.quorum()).assertEqual(TEST_QUORUM, "quorum is wrong");
    }

}