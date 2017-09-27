pragma solidity ^0.4.15;

contract OwnedInterface {

    event LogOwnerSet(address indexed previousOwner, address indexed newOwner);

    function setOwner(address newOwner) returns(bool success);
    function getOwner() constant returns(address currentOwner);
}