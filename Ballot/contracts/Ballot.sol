// SPDX-License-Identifier: MIT

pragma solidity ^0.7.1;

contract Ballot {
    
    struct Voter {
      uint weight;
      bool voted;
      uint vote;
    }
    
    struct Proposal{
        uint voteCount;
    }
    
    address public chairperson; // Ethereum address is 20 bytes long = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
    mapping(address => Voter) public voters;
    // {
    //     "0xabcd.1234" => {weight,voted,vote},
    //     "0xab12..def2" => {weight, voted,vote}
    // }
    // syntax for mapping and it is used to represent JSON structure in solidity
    // mapping( keyType => valueType ) public variable_name ;
    Proposal[] public proposals; 
    
    enum Phase {Init, Regs, Vote, Done}
    // it can take only 0,1,2,3 values:
    
    Phase public state = Phase.Done;
    
    constructor (uint numProposals) {
        chairperson = msg.sender;
        voters[chairperson].weight = 2;
        for(uint prop = 0 ; prop < numProposals ; prop++){
            // Proposal memory p;
            // p.voteCount = 0;
            // OR
            // Proposal memory p = Proposal(0);
            // proposals.push(p);
            // OR
            proposals.push(Proposal(0));
        }
        state = Phase.Regs;
    }
    
    modifier onlyChair() {
        require(msg.sender  == chairperson,"!chairperson");
        _;
    }
    
    modifier validPhase(Phase reqPhase) {
        require(state == reqPhase);
        _;
    }
    
    function changeState(Phase x) public onlyChair {
        require(x > state);
        state = x;
    }
    
    function register(address voter) public validPhase(Phase.Regs) onlyChair {
        require(voters[voter].voted == false);
        voters[voter].weight = 1;
    }
    
    function vote(uint toProposal) public validPhase(Phase.Vote) {
        Voter memory sender = voters[msg.sender];
        
        require(sender.voted == false);
        
        require(toProposal < proposals.length);
        
        voters[msg.sender].voted = true;
        voters[msg.sender].vote = toProposal;
        proposals[toProposal].voteCount += sender.weight;
    }
    
    function reqWinner() public validPhase(Phase.Done) view returns(uint) {
        uint winningVoteCount = 0;
        uint winningProposal = 0;
        for(uint prop = 0 ; prop < proposals.length ; prop++){
            if(proposals[prop].voteCount > winningVoteCount) {
                winningVoteCount = proposals[prop].voteCount;
                winningProposal = prop;
            }
        }
        assert(winningVoteCount >= 3);
        return winningProposal;
    }
}

/*
Truffle Develop started at http://127.0.0.1:9545/

Accounts:
(0) 0x2f70ea70106d69937001874832520a8df93ee303 -> chairPerson
(1) 0x3c735fb21647def65e25dee6d9ed7da92a22de0b -> voter1
(2) 0x1c7d9b8ce21de77fe7db2d9efe4f3b5a9aba6ec0 -> voter2
(3) 0xfc2579d08a85ae54a06b85d7bf36ae09832cebf6 -> voter3
(4) 0xa3e3d0565b19af992b316078f1b5ef5e698c922a -> voter4
(5) 0x6732441922435e9c2b9a61afd2148f8cd86a7bde -> voter5
(6) 0x5d1d6d9c1950396c9fe55adaf4bc41dae5598d64
(7) 0x2fe8dbafefc412c748068ddb795610b5d9b7bbc6
(8) 0xae8385bde6e265bb42aed5b3586eb395562b79dd
(9) 0x00616bd512960d330452be84e596c7101aaf417e

Private Keys:
(0) 4500acd6a46064e40c8d9ede1c638e8af325a3b48209da76125481b5d0afd492
(1) ed601a76c151dc01fe4665e5c301c820d923bf0f4e017b8ea1109b6663cdc3a4
(2) e272fd26e83f62fb21ae547e2289967f8610f6a53949e92d54a736b0203b2fc2
(3) 8a216674f6d1a8d20965a687b7ab5bafb9dfe71a83263eea56a7b1ed56cdd640
(4) d6ab690d230a333b66b19d74ed85cdabd48c7d5a7a4b1f928c903342177944f6
(5) 16e611487eebbb00088461b0bd0cd7bf3fedf201412e2366dcc587862c7e4089
(6) c6fec41e6c5ef90b76891d464e03345b86918bfb116619c66d1e9a0e60e99c8d
(7) 5a27d6e65029039c4ad41b4de44b83f6801de908ee9c20930fee93e65dc40be4
(8) 82ccc48fffdec97041ade45f5fc6623a2d0bdb458aa8109c8046e1d13f8e5922
(9) 35de83860f5d0e9b1090c91f7ef07e999a557414705ec09ada7fcb8412b00348

Mnemonic: initial twice resource cage pride session uniform fortune pet labor pave gloom

*/