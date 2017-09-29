pragma solidity ^0.4.15;

import "./IOwned.sol";

contract IEmployeeDirectory is IOwned {

    struct Employee {
      address[] allowedTokens;
      uint yearlyUSDSalary;
      uint lastAllocationDate;
      uint lastPayDate;
      uint contractEndDate;
      bool employed;
      uint index;
    }
    
    mapping(address => Employee) employees;
    address[] employeeIndex;

    modifier onlyEmployee {
        require(employees[msg.sender].employed);
        _;
    }

    function addEmployee(address employeeAddress, address[] allowedTokens, uint initialYearlyUSDSalary, uint contractEndDate) returns (bool success);
    function setEmployeeSalary(address employeeAddress, uint yearlyUSDSalary, uint contractEndDate) returns (bool success);
    function removeEmployee(address employeeAddress) returns (bool success);

    function getEmployeeCount() constant returns (uint count);
    function getEmployee(uint employeeId) constant returns
        (address employeeAddress, address[] allowedTokens, uint yearlyUSDSalary, uint lastAllocationDate, uint lastPayDate, uint contractEndDate, bool employed); 

    event LogNewEmployee(address sender, address indexed employeeAddress, address[] allowedTokens, uint initialYearlyUSDSalary, uint contractEndDate);
    event LogUpdatedEmployee(address sender, address indexed employeeAddress, uint initialYearlyUSDSalary, uint contractEndDate);
    event LogRemoveEmployee(address sender, address indexed employeeAddress);
}
