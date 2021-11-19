// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "./ERC20/ERC20.sol";


contract splitter is ERC20 {
    
    
    mapping(address => uint256) private _userBalance;
    mapping(address => uint256) private _userReleased;
    uint256 public _totalUserReleased;
    
    // this variable can be changed by the endVote function
    uint256 public _fee = 5; 
    address private _owner = msg.sender;
    
    uint256 public dividend;
    

    function transfer(address recipient) public payable {
        _userBalance[recipient]+=msg.value;
    }


    function userRelease(address payable account) public virtual {
        
        require(_userBalance[account] > 0, "PaymentSplitter: account balance is 0");
        
        uint256 totalReceived = address(this).balance + _totalUserReleased;
        uint256 payment = (_userBalance[account] * (100 - _fee)) / 100;

        require(payment != 0, "PaymentSplitter: account is not due payment");
        
        dividend += (totalReceived * _fee) / 100;

        _userReleased[account] += payment;
        _totalUserReleased += payment;

        Address.sendValue(account, payment);
    }



    /** Triggers a transfer to [account] of the amount of Ether they are owed, according to their percentage of the
        total shares and their previous withdrawals.

    */
    function release(address payable account) public virtual {
        require(_balances[account] > 0, "PaymentSplitter: account has no shares");

        uint256 totalReceived = dividend + _totalReleased;
        uint256 payment = (totalReceived * _balances[account]) / _totalSupply - _released[account];

        require(payment != 0, "PaymentSplitter: account is not due payment");

        _released[account] += payment;
        _totalReleased += payment;

        Address.sendValue(account, payment);
        emit PaymentReleased(account, payment);
    }


    // make a donation function to share holders 
    function contractDonation() public payable {
        dividend += msg.value;
    }


    // function updateFee will eventually be deleted 
    function updateFee(uint256 fee) public {
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
        return _userBalance[account];
    }
    
    
    function totalUserReleased() public virtual returns (uint256) {
        return _totalUserReleased;
    }

    // @dev - weird function consider editing or deleting
    function releasedinit(address account) public virtual returns (uint256) {
        return _userReleased[account];
    }

}