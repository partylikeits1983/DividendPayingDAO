// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
/// @title Voting with delegation.


import "./ERC20.sol";


contract simpleDAO is DAOtoken {
     

    //mapping(address => uint256) private _balances;
    
    uint public voteEndTime;
    
    //uint256 private _totalSupply;
    
    // allow withdrawals
    //mapping(address=>uint) public _balances;
    
    // proposal decision of voters 
    uint decision;

    // default set as false 
    // makes sure votes are counted before ending vote
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

    //error handlers

    /// The vote has already ended.
    error voteAlreadyEnded();
    /// The auction has not ended yet.
    error voteNotYetEnded();
    
    
    uint _voteTime = 20; //1209600;
    //string[] proposalNames = ["2", "6"];

    //uint256 totalsupply = 100;
    
    
    function createProposal(uint256[] memory proposalNames) public payable {
        
        require(_balances[msg.sender] != 0, "this account has no shares");
        require(proposalNames.length == 1, "you can only create one proposal at a time");
        
        require(msg.value >= 1 ether, "you must pay 1 ether");
        dividend += msg.value;
        
        // person who creates proposal must have 10 percent of totalsupply *subject to change...
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
    
    
    
    function showPercentage(address account) public view returns (uint256) {
        // test function to see percent required for proposal creation
        uint256 percent = ( 100000 * _balances[account] ) / _totalSupply;
        return percent; 
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
    }

    // winningProposal must be executed before EndVote
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
    

    function EndVote() external payable 
            returns (uint fee) 
        {
        require(
            block.timestamp > voteEndTime,
            "Vote not yet ended.");
          
            
        fee = proposals[countVote()].fee;
        
        delete proposals;
        //delete voters[;
        ended = false;
  
        }
    
}
