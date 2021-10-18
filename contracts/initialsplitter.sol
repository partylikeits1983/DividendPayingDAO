// SPDX-License-Identifier: MIT

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol";

pragma solidity ^0.8.0;
/* @dev rename these functions in PaymentSplitter */
contract PaymentSplitter is Context {

    uint256 private _totalReleased;
    mapping(address => uint256) private _released;
    address[] private _payees;
    
    uint256 private _fee = 5;
    address private _owner = msg.sender;

    mapping(address => uint256) private _balances;
    
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
 
}
