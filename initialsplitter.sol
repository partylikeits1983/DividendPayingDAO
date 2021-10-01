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
    address private _tokenaddress;
    address private _owner;
    uint256 private _fee;



    constructor(uint256 fee_) {
        _owner = msg.sender;
        _fee = fee_;
    }



    function totalReleased() public view returns (uint256) {
        return _totalReleased;
    }


    function released(address account) public view returns (uint256) {
        return _released[account];
    }




    function release(address payable account) public virtual {

        uint256 totalReceived = address(this).balance + _totalReleased;
        uint256 payment = (totalReceived * (100 - _fee)) / 100 - _released[account];

        require(payment != 0, "PaymentSplitter: account is not due payment");

        _released[account] = _released[account] + payment;
        _totalReleased = _totalReleased + payment;

        Address.sendValue(account, payment);

    }


    function updeateTokenAddress(address account) public {
        require(msg.sender == _owner, "Only the owner");
        _tokenaddress = account;
        
    }
    
    function updeateFee(uint256 fee) public {
        require(msg.sender == _owner, "Only the owner");
        _fee = fee;
    }
    
    
    
    function owner() public view returns (address) {
        return _owner;
    }
    
    
    function tokenAddress() public view returns (address) {
        return _tokenaddress;
    }


        
    function transfer(address recipient) public payable {
        
        _balances[recipient]+=msg.value;

    }
    
    
    
    function getBalance() public view returns(uint){
        return address(this).balance;
    }
    
    
    
    function getUserBalance(address account) public view returns(uint256){
        return _balances[account];
    }
 
    
    
    
    
}







