//SPDX-License_Identifier: minutes
pragma solidity ^0.7.1;

import "./ExternalCall.sol";

interface IPriceFeed{
    function getPrice() external view returns(uint);
}

//contract Consumer{
    
    
//    function callFeed (address _priceFeed) public view returns(uint){
        //instance of the contract
//        return IPriceFeed(_priceFeed).getPrice();
//    }
//}

contract ConsumerV2{
    PriceFeed public priceFeedContract;
    
    constructor (address _priceFeed){
        priceFeedContract = PriceFeed(_priceFeed);
    }
    
    function callFeed() public view returns(uint){
        return priceFeedContract.getPrice();
    }
}