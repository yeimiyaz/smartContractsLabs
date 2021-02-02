const Ballot = artifacts.require("Ballot");
const truffleAssert = require("truffle-assertions");

contract("Ballot", (accounts) => {
    //Enum of phases
    const PhaseExpected = {
        Init: { value: 0, name: "Init" },
        Regs: { value: 1, name: "Regs" },
        Vote: { value: 2, name: "Vote" },
        Done: { value: 3, name: "Done" }
    };

    //variables and constants
    let ballotInstance;
    const chairpersonExpected = accounts[0];
    const stateInitialExpected = PhaseExpected.Regs;
    const voter1 = accounts[1];
    const voter2 = accounts[2];
    const voter3 = accounts[3];
    const voter4 = accounts[4];
    const stateRegs = PhaseExpected.Regs;
    const stateVote = PhaseExpected.Vote;
    const stateDone = PhaseExpected.Done;
    const proposal1 = 0;
    const proposal2 = 1;
    const winnerExpected = 0; 

    before(async () => {
        ballotInstance = await Ballot.deployed();
    });

    it("validate the expected chairperson", async () => {
        const chairperson = await ballotInstance.chairperson.call();
        assert.equal(chairperson, chairpersonExpected, "Chairperson is not as expected");
    });

    it("validate the expected state", async () => {
        const state = await ballotInstance.state.call();
        assert.equal(stateInitialExpected.value, state, "The state is different");
    });

    it("register voters", async () => {
        //check the state in Phase.Regs to register the voters
        let checkState = await ballotInstance.state.call();
        assert.equal(stateRegs.value, checkState, `The state is different than ${stateRegs} to register a voter`);

        //register voter1
        await ballotInstance.register(voter1, { from: chairpersonExpected })

        //consult the address of the voter1 in the array of voters
        let registerVoters = await ballotInstance.voters.call(voter1);

        //consult the property "voted" of the voter1
        voted = registerVoters[1];

        //consult that voter1 has not voted yet because it was just registered
        assert.equal(false, voted, 'There is a problem with the registration of the voter 1');

        //register voter2
        await ballotInstance.register(voter2, { from: chairpersonExpected })

        //consult the address of the voter2 in the array of voters
        registerVoters = await ballotInstance.voters.call(voter2);

        //consult the property "voted" of the voter2
        voted = registerVoters[1];

        //consult that voter2 has not voted yet because it was just registered
        assert.equal(false, voted, 'There is a problem with the registration of the voter 2');

        //register voter3
        await ballotInstance.register(voter3, { from: chairpersonExpected })

        //consult the address of the voter3 in the array of voters
        registerVoters = await ballotInstance.voters.call(voter3);

        //consult the property "voted" of the voter3
        voted = registerVoters[1];

        //consult that voter3 has not voted yet because it was just registered
        assert.equal(false, voted, 'There is a problem with the registration of the voter 3');

        //register voter4
        await ballotInstance.register(voter4, { from: chairpersonExpected })

        //consult the address of the voter4 in the array of voters
        registerVoters = await ballotInstance.voters.call(voter4);

        //consult the property "voted" of the voter1
        voted = registerVoters[1];

        //consult that voter4 has not voted yet because it was just registered
        assert.equal(false, voted, 'There is a problem with the registration of the voter 4');
    })

    it("change state to vote", async () => {
        //consult previous state
        let previousState = await ballotInstance.state.call();

        //change the state to Vote
        await ballotInstance.changeState(stateVote.value, { from: chairpersonExpected });

        //consult new state
        let newState = await ballotInstance.state.call();

        //validate changes in states
        assert.notEqual(previousState, newState, 'The state did not change');

        //validate that new state is Vote
        assert.equal(stateVote.value, newState, 'The state did not change to vote');
    })

    it("vote", async () => {

        let numberVotesProposal1 = 0;
        
        //voter1 votes for proposal1
        await ballotInstance.vote(proposal1, { from: voter1 });
        numberVotesProposal1++;

        //consult the property "voted" of voter1 to validate the vote process
        let voted = await ballotInstance.voters.call(voter1);
        assert.equal(true, voted[1], 'The voter1 should have true in the voted attribute');

        //voter2 votes for proposal1
        await ballotInstance.vote(proposal1, { from: voter2 });
        numberVotesProposal1++;

        //voter3 votes for proposal1
        await ballotInstance.vote(proposal1, { from: voter3 });
        numberVotesProposal1++;

        //voter4 votes for proposal2
        await ballotInstance.vote(proposal2, { from: voter4 });

        //consult the number of votes for a proposal
        return ballotInstance.proposals.call(proposal1).then(result => {
            assert.equal(numberVotesProposal1, result, 'The number of votes for a proposal1 do not correspond with the expected number');
        });

    })

    it("validation reqWinner", async () => {

        //change the state to Done
        await ballotInstance.changeState(stateDone.value, { from: chairpersonExpected });

        //execute the function reqWinner to determine the winner of the ballot
        let winner = await ballotInstance.reqWinner();

        //Validate the winner
        assert.equal(winnerExpected, winner, 'There is a wrong winner');
    })
}); 