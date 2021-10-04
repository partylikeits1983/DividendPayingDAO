// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol";

contract PaymentSplitter is Context {

    uint256 private _totalReleased;
    mapping(address => uint256) private _released;
    address[] private _payees;

   /**
    * all my crap
    */

    mapping(address => uint256) private _balances;
    address payable private _tokenaddress;
    address private _owner;
    uint256 private _fee;
    
    uint256 private dividend;


    constructor(uint256 fee_) {
        _owner = msg.sender;
        _fee = fee_;
    }



    function transfer(address recipient) public payable {
        _balances[recipient]+=msg.value;
    }


    function release(address payable account) public virtual {
        require(_tokenaddress != account, "PaymentSplitter: Account cannot be token address");
        require(_balances[account] > 0, "PaymentSplitter: account balance is 0");
        
        uint256 totalReceived = address(this).balance + _totalReleased;
        uint256 payment = (_balances[account] * (100 - _fee)) / 100;
        
        dividend = (totalReceived * _fee) / 100 - _released[_tokenaddress];

        require(payment != 0, "PaymentSplitter: account is not due payment");

        _released[account] = _released[account] + payment;
        _totalReleased = _totalReleased + payment;

        Address.sendValue(account, payment);
    }


    function releaseDividend() public virtual {
        require(dividend != 0, "PaymentSplitter: account is not due payment");

        _released[_tokenaddress] = _released[_tokenaddress] + dividend;
        _totalReleased = _totalReleased + dividend;

        Address.sendValue(_tokenaddress, dividend);
    }


    function updeateTokenAddress(address payable account) public {
        require(msg.sender == _owner, "Only the owner");
        _tokenaddress = account;
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
    
    
    function tokenAddress() public view returns (address) {
        return _tokenaddress;
    }


    function getBalance() public view returns(uint){
        return address(this).balance;
    }
    
    
    function getDividend() public view returns(uint256){
        return dividend;
    }
    
    
    function getUserBalance(address account) public view returns(uint256){
        return _balances[account];
    }
    
    
    function totalReleased() public view returns (uint256) {
        return _totalReleased;
    }


    function released(address account) public view returns (uint256) {
        return _released[account];
    }
 
}
