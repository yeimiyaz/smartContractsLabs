// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;

contract PriceFeed{
    uint private price = 2;
    
    function getPrice() public view returns(uint){
        return price;
    }
    
    function setPrice(uint _price) public{
        price =_price;
    }
}

library ConvertLib{
    function convert(uint _amount, uint _conversionRate) public pure returns (uint convertamount){
        return _amount * _conversionRate;
    }
}

contract MetaCoin{
    mapping(address => uint) balances;
    
    event Transfer(address _from, address _to, uint _amount);
    
    PriceFeed public feed;
    
    constructor(PriceFeed _feed){
        feed =_feed;
        balances[msg.sender] = 10000;
    }
    
    function sendCoin(address _receiver, uint _amount) public returns(bool _sufficient){
    //validate balance of caller is higher than _amount
    require(balances[msg.sender] >= _amount, "Insuficient balance");
    balances[msg.sender] = balances[msg.sender] - _amount;
    balances[_receiver] = balances[_receiver] + _amount;
    emit Transfer(msg.sender, _receiver, _amount);
    _sufficient = true;
}
    
    //Allow all the token owner get the balances
    function getBalance(address _account) public view returns(uint _balance){
        _balance = balances[_account];
    }
    
    //What is the price or exchange rate of your token
    function getBalanceInEth(address _account) public view returns (uint _balanceInEth){
        uint _exchangeRate = feed.getPrice();
        //_balanceInEth = balances[_account]*_exchangeRate; 
        _balanceInEth = ConvertLib.convert(balances[_account], _exchangeRate);
        
        
    }
}