//SPDX-License_Identifier: minutes
pragma solidity ^0.7.1;


contract ReceiveEther{
    
    //To receive Ether, it is necessary to implement the following function. msg.data is empty
    
    receive() external payable{}
    
    // msg.data is not empty
    fallback() external payable{}
    
    function getBalance() public view returns (uint){
        return address(this).balance;
    }
}

//send ether from one contract to another contract
// Transfer

contract SendEther{
    // sending via "transfer" - payable
    function sendViaTransfer(address payable _receiver) public payable{ // receiver can be an EOA or a contract
        // If you want to same the same value that you reive use msg.value
        _receiver.transfer(msg.value);
    }
    
    // sending via send
    // most efficient and versatile way to transfer Ether
    // access to the success to validate the execution of the transaction
    function sendViaSend(address payable _receiver) public payable{ // receiver can be an EOA or a contract
        // If you want to send the same value that you receive use msg.value
        bool _success = _receiver.send(msg.value); // send has a return value
        require(_success, "Ether transfer failed");
    }
    
    function sendViaCall(address payable _receiver) public payable{
        //recommend
        (bool _success, bytes memory data) = _receiver.call{value:msg.value}("");//low-level call
        require(_success, "Ether transfer failed");
    }
}
