pragma solidity ^0.4.15;

import "./interfaces/OwnedInterface.sol";

contract Owned is OwnedInterface { 

    address owner;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function Owned() public { 
        owner = msg.sender;
    }
    
    function setOwner(address newOwner) 
        onlyOwner
        public
        returns(bool success) {
            require(newOwner != address(0));
            require(newOwner != owner);

            owner = newOwner;

            LogOwnerSet(msg.sender, newOwner);
            return true;
        }

    function getOwner() 
        constant
        public
        returns(address currentOwner) { 
            return owner;
        }
}