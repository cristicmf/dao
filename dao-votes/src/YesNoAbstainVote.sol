/*
    File: YesNoAbstainVote.sol

    Author: Andreas Olofsson (androlo1980@gmail.com)
*/
import "./Ballot.sol";

/*
    Contract: YesNoAbstainVote

    An interface contract for yes/no/abstain votes.

*/
contract YesNoAbstainVote {

    /*
        Enum: Vote

        An enumeration of different vote values.

        Null - Null vote.

        Yes - A yes vote.

        No - A no vote.

        Abstain - An abstain vote.
    */
    enum Vote {Null, Yes, No, Abstain}

    /*
        Function: vote

        Called to cast a vote.

        Params:
            voter (address) - The voter address.
            vote (uint8) - The vote. See <Vote>.
            timestamp (uint) - The time when the vote is made.

        Returns:
            error (uint16) - An error code.
    */
    function vote(address voter, uint8 vote, uint timestamp) returns (uint16 error);

    /*
        Function: voteData

        Get voter data from their account address.

        Params:
            index (uint) - The index.

        Returns:
            vote (uint8) - The vote. See <Vote>.
            error (uint16) - An error code.
    */
    function voterData(address voterAddress) constant returns (uint8 vote, uint16 error);

    /*
        Function: voteDataFromIndex

        Get voter data from their index in the backing array. Used for iterating.

        Params:
            index (uint) - The index.

        Returns:
            addr (address) - The voter address.
            vote (uint8) - The vote. See <Vote>.
            error (uint16) - An error code.
    */
    function voterDataFromIndex(uint index) constant returns (address addr, uint8 vote, uint16 error);

    /*
        Function: result

        Get the result of the vote.

        Returns:
            result (int) - The result of the vote.
    */
    function result() constant returns (int result);

}