// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol";

//import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "https://github.com/partylikeits1983/DividendPayingDAO/blob/67bb1c591f9cb322d75fab78ed3dc2ba1721b02c/contracts/initialsplitter.sol";

contract simpleDAO {
    
   
    // address of vending machine
    address payable public VendingMachineAddress;
    
    uint public voteEndTime;
    
    // balance of ether in the smart contract
    uint public DAObalance;
    
    // allow withdrawals
    mapping(address => uint256) public _balances;
    
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
        string name;   // short name (up to 32 bytes)
        uint voteCount; // number of accumulated votes
    
    }

    // address of the person who set up the vote 
    

    mapping(address => Voter) public voters;
    Proposal[] public proposals;

    //error handlers

    /// The vote has already ended.
    error voteAlreadyEnded();
    /// The auction has not ended yet.
    error voteNotYetEnded();
    
    
    uint _voteTime = 200000000;
    string[] proposalNames = ["2","4"];


    // Sample input string: ["buy_cupcakes", "no_cupcakes"]
    // First item in string is the one that will execute the purchase 
    // _VendingMachineAddress is the address where the ether will be sent
    constructor(
        

    ) {
        
        //chairperson = msg.sender;
        
        voteEndTime = block.timestamp + _voteTime;
        voters[msg.sender].weight = 0;

        for (uint i = 0; i < proposalNames.length; i++) {

            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }
    
    
    


    // proposals are in format 0,1,2,...
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
    function countVote() public
            returns (uint winningProposal_)
            
    {
        require(
            block.timestamp > voteEndTime,
            "Vote not yet ended.");
        
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
                
                decision = winningProposal_;
                ended = true;
            }
        }
    }


    // ends the vote
    // if DAO decided not to buy cupcakes members can withdraw deposited ether
    function EndVote() public {
        require(
            block.timestamp > voteEndTime,
            "Vote not yet ended.");
          
        require(
            ended == true,
            "Must count vote first");  
            
            
        require(
            decision == 0,
            "DAO decided to not buy cupcakes. Members may withdraw deposited ether.");
            
            
        if (DAObalance  < 1 ether) revert();
            (bool success, ) = address(VendingMachineAddress).call{value: 1 ether}(abi.encodeWithSignature("purchase(uint256)", 1));
            require(success);
            
        DAObalance = address(this).balance;
  
        }
    
}


contract ERC20 is Context, IERC20, IERC20Metadata, PaymentSplitter, simpleDAO {
    // @dev seems a bit sketch that _balances is in simpleDAO but it may work...
    //mapping(address => uint256) private _balances;

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

    constructor(
        string memory name_, 
        string memory symbol_, 
        uint supply,
        address[] memory payees, 
        uint256[] memory amount) payable {
            
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

