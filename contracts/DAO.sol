// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./splitter.sol";

contract DAO is splitter {
    
    uint public voteEndTime;
    
    //quorum is 100 million which is 10% of total supply
    uint256 public quorum = 100000000000000000000000000;


    bool ended;
    

    struct Voter {
        uint weight; // weight is accumulated by delegation
        bool voted;  // if true, that person already voted
        address delegate; // person delegated to
        uint vote;   // index of the voted proposal
    }

    struct Proposal {
        uint256 fee;   // short name (up to 32 bytes)
        uint voteCount; // number of accumulated votes
    
    }
    
    
    mapping(address => Voter) public voters;
    Proposal[] public proposals;
    address[] public voterAddress;


    //error handlers
    /// The vote has already ended.
    error voteAlreadyEnded();
    /// The auction has not ended yet.
    error voteNotYetEnded();
    
    // SET VOTE TIME
    uint _voteTime = 20; //1209600; 2 WEEKS

    
    function createProposal(uint256[] memory proposalNames) public payable {
        
        require(_balances[msg.sender] != 0, "this account has no shares");
        require(proposalNames.length == 1, "you can only create one proposal at a time");
        
        require(msg.value >= 1 ether, "you must pay 1 ether");
        dividend += msg.value;
        
        // MUST HAVE 10 PERCENT TO CREATE PROPOSAL *subject to change... (10000 because it allows to calculate percent to 5 decimals)
        uint256 percent = ( 100000 * _balances[msg.sender] ) / _totalSupply;
        
        require(percent >= 10000);
        
        voteEndTime = block.timestamp + _voteTime;
         
        for (uint i = 0; i < proposalNames.length; i++) {
        
            proposals.push(Proposal({
                fee: proposalNames[i],
                voteCount: 0
        }));
        }
    }
    

    
    function vote(uint proposal) public {
        
        require(_balances[msg.sender] !=0, "zero balance");
        uint256 voteWeight = _balances[msg.sender];
        
        voters[msg.sender].weight = voteWeight;
        
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;
        proposals[proposal].voteCount += sender.weight;
        
        voterAddress.push(msg.sender);
    }
    

    // CONSIDER MAKING FUNCTION PRIVATE - this function can be called before vote end 
    function countVote() public view
            returns (uint winningProposal_)
        {
            
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }
    
    
    // NEEDS TO BE EXTENSIVELY TESTED
    function EndVote() public {
        require(
            block.timestamp > voteEndTime,
            "Vote not yet ended.");
          
        uint256 fee;
        uint votes;
        fee = proposals[countVote()].fee;
        votes = proposals[countVote()].voteCount;
        
        require(fee <= 10, "fee cannot be set higher than 10 percent");
        
        require(votes >= quorum, "quorum was not met");
        
        // if criteria are met, fee is set and struct Voters is reset 
        if(fee <= 10 && votes >= quorum) {   
            // DAO UPDATES FEE
            _fee = fee;
        
            for (uint i = 0; i < voterAddress.length; i++)
                delete voters[voterAddress[i]];
        
        // even if criteria are not met, struct Voters is reset 
        } else {
            
            for (uint i = 0; i < voterAddress.length; i++)
                delete voters[voterAddress[i]];
        
        } 
        // delete voter address array
        delete voterAddress;
            
        }
    
}
