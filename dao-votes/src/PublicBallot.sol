/*
    File: PublicBallot.sol

    Author: Andreas Olofsson (androlo1980@gmail.com)
*/
import "./Ballot.sol";
import "dao-stl/src/contracts/Executor.sol";

/*
    Contract: PublicBallot

    An interface contract for public ballots. This is a very complex vote
    that requires its own contract. It allows for any number of voters.
    Simpler voting contracts done by a handful of voters can be done wih a
    struct + library combination instead.
*/
contract PublicBallot is Ballot {

    /*
        Event: Finalize

        Params:
            passed (bool) - Whether or not the vote passed.
            error (uint16) - Error code for the function.
            execError (uint16) - Error code for the action triggered by the vote.
    */
    event Finalize(bool indexed passed, uint16 indexed error, uint16 indexed execError);

    /*
        Function: finalize

        Called to finalize a vote.

        Returns:
            passed (bool) - Whether or not the vote passed.
            error (uint16) - Error code for the function.
            execError (uint16) - Error code for the action triggered by the vote.
    */
    function finalize() returns (bool passed, uint16 error, uint16 execError);

    /*
        Function: userDatabase

        Get the address of the user database.

        Returns:
            userDatabase (address) - The address.
    */
    function userDatabase() constant returns (address userDatabase);

    /*
        Function: quorum

        Get the quorum. It is a number between 0 and 100, used as a percentage in calculations.

        Returns:
            quorum (uint16) - The quorum.
    */
    function quorum() constant returns (uint16 quorum);

}