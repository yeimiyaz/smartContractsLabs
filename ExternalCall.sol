//SPDX-License_Identifier: minutes
pragma solidity ^0.7.1;


//Oracle contract
//Useful for getting information in exchange

contract PriceFeed{
    uint private price = 42;
    
    function getPrice() public view returns (uint){
        return price;
    }
    
    // only change the price if it receives 1 ether
    function setPrice(uint _price) public payable{
        require(msg.value == 1 ether, "Amount should be equal to 1 Ether");
        price = _price;
    }
    
}

// Send 1 eher with the parameter _price
contract ConsumerModified{
    function callSetPrice(PriceFeed feed, uint _price) public payable{
        feed.setPrice{value:msg.value}(_price);
    }
}

//In the execution of the contract it is necessary to pass in callfeed the address of the oracle contract
//Consume the function price from the PriceFeed contract
contract Consumer{
    function callFeed (PriceFeed feed) public view returns(uint){
        //instance of the contract
        return feed.getPrice();
    }
}
