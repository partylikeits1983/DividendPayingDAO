// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol";

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";


contract ERC20 is Context, IERC20, IERC20Metadata {
    
    /**
    
    INITIAL SPLITTER
    
    */

    //uint256 private _totalReleased;
    //mapping(address => uint256) private _released;
    //address[] private _payees;
    //mapping(address => uint256) private _balances;
    
    uint256 private _fee = 5;
    address private _owner = msg.sender;
    
    uint256 public dividend;

    address _tokenaddress = address(this);
    
    function transfer(address recipient) public payable {
        _balances[recipient]+=msg.value;
    }


    function releaseinit(address payable account) public virtual {
        
        require(_balances[account] > 0, "PaymentSplitter: account balance is 0");
        
        uint256 totalReceived = address(this).balance + _totalReleased;
        uint256 payment = (_balances[account] * (100 - _fee)) / 100;
        
        dividend += (totalReceived * _fee) / 100 - _released[_tokenaddress];

        require(payment != 0, "PaymentSplitter: account is not due payment");

        _released[account] = _released[account] + payment;
        _totalReleased = _totalReleased + payment;

        Address.sendValue(account, payment);
    }


    // make a donation function to share holders 
    function donation(uint256) public payable {
        dividend += msg.value;
    }

    
    function updeateFee(uint256 fee) public {
        require(msg.sender == _owner, "Only the owner");
        require(fee <= 10, "Fee must not be higher than 10%");
        _fee = fee;
    }
    
    
    function getfee() public view returns (uint256) {
        return _fee;
    }
    
    
    function owner() public view returns (address) {
        return _owner;
    }
    
    
    function getUserBalance(address account) public view returns(uint256){
        return _balances[account];
    }
    
    
    function totalReleasedinit() public virtual returns (uint256) {
        return _totalReleased;
    }


    function releasedinit(address account) public virtual returns (uint256) {
        return _released[account];
    }
    
    
    function seeDividend() public view returns (uint256) {
        return dividend;
    }
 



    /**
    
    VOTING
    
    */
    
    uint public voteEndTime;
    
    //quorum is 100 million which is 10% of total supply
    uint256 public quorum = 100000000000000000000000000;

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
    address[] public voterAddress;


    //error handlers
    /// The vote has already ended.
    error voteAlreadyEnded();
    /// The auction has not ended yet.
    error voteNotYetEnded();
    
    
    uint _voteTime = 20; //1209600; 2 WEEKS

    
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
        
        voterAddress.push(msg.sender);
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
    

    
    /**
    
    TOKEN
    
    */


    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;
    
    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    
    
    event PayeeAdded(address account, uint256 shares);
    event PaymentReleased(address to, uint256 amount);
    event PaymentReceived(address from, uint256 amount);
    
    mapping(address=>uint) ethbalance;
    
    uint256 private _totalReleased;
    
    mapping(address => uint256) private _released;
    address[] private _payees;
    
    
    // hardcoded the constructor for faster development... more warnings but its ok for now... 1B supply
    string name_ = "asdf";
    string symbol_ = "xyz";
    uint supply = 1000000000000000000000000000;
    address[] payees = [0x5B38Da6a701c568545dCfcB03FcB875f56beddC4];
    uint256[] amount= [1000000000000000000000000000];
    

    constructor(
        
        /**
        string memory name_, 
        string memory symbol_, 
        uint supply,
        address[] memory payees, 
        uint256[] memory amount) payable {
        */
        
        
        ) payable {
        
        _name = name_;
        _symbol = symbol_;
        _mint(msg.sender, supply);
        require(payees.length == amount.length, "PaymentSplitter: payees and shares length mismatch");
        require(payees.length > 0, "PaymentSplitter: no payees");
        
        for (uint256 i = 0; i < payees.length; i++) {
            _addPayee(payees[i], amount[i]);
        }
      
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }
    

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    
    
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }


    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }
    

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }
    

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
  
        }
        
        _balances[recipient] += amount;
        _payees.push(recipient);
        
        emit Transfer(sender, recipient, amount);
        _afterTokenTransfer(sender, recipient, amount);
        
        //** adds new account to _payees array and how many 
        _payees.push(recipient);
        _balances[recipient] = amount;

    }


    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }
    

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }


    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}



    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
    
    
    
    receive() external payable virtual {
        emit PaymentReceived(_msgSender(), msg.value);
    }
    
    
    
    function getBalance() public view returns(uint){
        return address(this).balance;
    }
    
    
    /**
     * @dev Getter for the total amount of Ether already released.
     */
    function totalReleased() public view returns (uint256) {
        return _totalReleased;
    }


    /**
     * @dev Getter for the amount of shares held by an account.
     */
    function shares(address account) public view returns (uint256) {
        return _balances[account];
    }


    /**
     * @dev Getter for the amount of Ether already released to a payee.
     */
    function released(address account) public view returns (uint256) {
        return _released[account];
    }


    /**
     * @dev Getter for the address of the payee number `index`.
     */
    function payee(uint256 index) public view returns (address) {
        return _payees[index];
    }
    

    /**
     * @dev Triggers a transfer to `account` of the amount of Ether they are owed, according to their percentage of the
     * total shares and their previous withdrawals.
     */
    function release(address payable account) public virtual {
        require(_balances[account] > 0, "PaymentSplitter: account has no shares");

        uint256 totalReceived = dividend + _totalReleased;
        uint256 payment = (totalReceived * _balances[account]) / _totalSupply - _released[account];

        require(payment != 0, "PaymentSplitter: account is not due payment");

        _released[account] = _released[account] + payment;
        _totalReleased = _totalReleased + payment;

        Address.sendValue(account, payment);
        emit PaymentReleased(account, payment);
    }



    function _addPayee(address account, uint256 amount) private {
        require(account != address(0), "PaymentSplitter: account is the zero address");
        require(amount > 0, "PaymentSplitter: shares are 0");
        /** require(_balances[account] == 0, "PaymentSplitter: account already has shares"); **/

        _payees.push(account);
        _balances[account] = amount;
        
        emit PayeeAdded(account, amount);
    }
}
