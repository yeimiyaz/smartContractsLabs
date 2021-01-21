pragma solidity ^0.5.0;

contract tipJar {
    
    address private owner; 
    
    constructor () public payable{
        owner = msg.sender;
    }
    
    // Fallback payable function
    function () external payable{
        
    }
    
    // Function to pick up the ether buy the owner
    function pickTipJar () public {
        require(msg.sender == owner, "sorry you are not the owner, so you cannot pick up the coins");
        
        msg.sender.transfer(address(this).balance);
            
    }
    
    // Function to validate the contract
    function putTip() public payable{
        
    }
}
