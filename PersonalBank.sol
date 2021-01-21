pragma solidity ^0.5.0;

contract PersonalBank {
    address owner;
    
    //mapping of the cheques already cashed
    mapping(bytes32 => bool) chequesAlreadyCashed;
    
    constructor() public payable {
        owner = msg.sender;
    }
    
    function() external payable {
    }
    
    function cashCheque(address payable to, uint256 amount, bytes32 nonce, 
                        bytes32 r, bytes32 s, uint8 v)
                public {
        
        //the message includes the nonce and address
        bytes32 messageHash = keccak256(abi.encodePacked(to, amount, nonce, address(this)));
        
       //validation of the cheques that have been already cashed
        require(!chequesAlreadyCashed[messageHash], "sorry this check has been already cashed");
        
            chequesAlreadyCashed [messageHash] = true;
            bytes32 messageHash2 = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32", messageHash
            ));
        
            require(ecrecover(messageHash2, v, r, s) == owner, "bad signature");
        
            to.transfer(amount);
      }
}