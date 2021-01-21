// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;

contract ComputeContractAddress{
    function getAddr(address _addr, byte _nonce) public pure returns(address){
        return address(uint160(uint256(keccak256(abi.encodePacked(byte(0xd6), byte(0x94), _addr, byte(_nonce))))));
    }
}

//0x755014Da263Fc47d238078Bb47d217F743E5B6a5
//The address of the creator contract is 0x692a70D2e424a56D2C6C27aA97D1a86395877b3A
//nonce 0x01 for the nonce