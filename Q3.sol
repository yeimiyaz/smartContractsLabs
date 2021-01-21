// SPDX-License-Identifier: MIT



pragma solidity ^0.7.1;

 

contract PriceFeed {
    uint private price = 42;
    
    function setPrice(uint newPrice) public payable { 
        price = newPrice; 
    }
    
    function getPrice() public returns (uint) { 
        return price; 
    }
    
    function getSender() public view returns (address) { 
        return msg.sender; 
    }
    
    function getOrigin() public view returns (address) { 
        return tx.origin; 
    }
    
    function getAddress() public view returns (address) { 
        return address(this); 
    }
    
}

contract Caller {
    event logResult(string, bytes);
    address public feed;
    uint public price = 33;
    
    event AddedValuesByDelegateCall(uint _value, bool success);
    
    function setup(address addr) public {
        require(addr != address(0));
        feed = addr;
    }

    function getPrice() public returns(uint) {
        (bool success, bytes memory ret) =
        feed.delegatecall(abi.encodeWithSignature("getPrice()"));
        require(success);
        
        //emit logResult("getPrice", ret);
        return (abi.decode(ret, (uint)));
    }
    //0xB57ee0797C3fc0205714a577c02F7205bB89dF30
        //Q4 0xd2a5bC10698FD955D1Fe6cb468a17809A08fd005 -> address of Caller
    function getSenderStaticcall (address _addr) public view returns(address) {
        (bool success, bytes memory ret) =
        _addr.staticcall(abi.encodeWithSignature("getSender()"));
        require(success);
        
        //emit logResult("getPrice", ret);
        return (abi.decode(ret, (address)));
    }
    
        //Q5 {"0": "address: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4" Account of Caller - EOA
    function getSenderDelegate(address _addr)public returns(address) {
        (bool success, bytes memory ret) =
        _addr.delegatecall(abi.encodeWithSignature("getSender()"));
        require(success);
        
        //emit logResult("getPrice", ret);
        return (abi.decode(ret, (address)));
    }
    
        //Q6 {"0": "address: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4" EOA
    function getOriginStaticcall (address _addr) public view returns(address) {
        (bool success, bytes memory ret) =
        _addr.staticcall(abi.encodeWithSignature("getOrigin()"));
        require(success);
        
        //emit logResult("getPrice", ret);
        return (abi.decode(ret, (address)));
    }
    
        //Q7 {	"0": "address: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4" EOA

    function getOriginDelegate(address _addr) public returns(address) {
        (bool success, bytes memory ret) =
        _addr.delegatecall(abi.encodeWithSignature("getOrigin()"));
        require(success);
        
        //emit logResult("getPrice", ret);
        return (abi.decode(ret, (address)));
    }
    
    //{	"0": "address: 0x9d83e140330758a8fFD07F8Bd73e86ebcA8a5692" Address of the PriceFeed

    
    function getAddressStaticcall (address _addr) public view returns(address) {
        (bool success, bytes memory ret) =
        _addr.staticcall(abi.encodeWithSignature("getAddress()"));
        require(success);
        
        //emit logResult("getPrice", ret);
        return (abi.decode(ret, (address)));
    }
    
    // 0xD4Fc541236927E2EAf8F27606bD7309C1Fc2cbee
    // {"0": "address: 0xD4Fc541236927E2EAf8F27606bD7309C1Fc2cbee"  Address of the caller

    function getAdressDelegate(address _addr) public returns(address) {
        (bool success, bytes memory ret) =
        _addr.delegatecall(abi.encodeWithSignature("getAddress()"));
        require(success);
        
        //emit logResult("getPrice", ret);
        return (abi.decode(ret, (address)));
    }

    function setPriceCall(address _addr, uint _value) public payable{
        (bool success, bytes memory ret) = _addr.delegatecall(abi.encodeWithSignature("setPrice(uint)", _value));
        emit AddedValuesByDelegateCall(_value, success);
        
    }
 
}


// EOA cuenta del que llama al contrato

    /*function getPrice() public view returns(uint) {
        (bool success, bytes memory ret) =
        feed.staticcall(abi.encodeWithSignature("getPrice()"));
        require(success);
        
        //emit logResult("getPrice", ret);
        return (abi.decode(ret, (uint)));
    }*/
    
    

