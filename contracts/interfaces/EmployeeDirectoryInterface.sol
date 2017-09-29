pragma solidity ^0.4.15;

import "./OwnedInterface.sol";

contract EmployeeDirectoryInterface is OwnedInterface {

    event LogNewEmployee(address sender, address indexed employeeAddress, address[] allowedTokens, uint initialYearlyUSDSalary);
    event LogUpdatedEmployeeSalary(address sender, address indexed employeeAddress, uint initialYearlyUSDSalary);
    event LogRemoveEmployee(address sender, address indexed employeeAddress);

    function addEmployee(address employeeAddress, address[] allowedTokens, uint initialYearlyUSDSalary) returns (bool success);
    function setEmployeeSalary(address employeeAddress, uint yearlyUSDSalary) returns (bool success);
    function removeEmployee(address employeeAddress) returns (bool success);

    function getEmployeeCount() constant returns (uint count);
    function getEmployee(uint employeeId) constant returns (address employeeAddress); 
}
