pragma solidity ^0.4.15;

import "./interfaces/EmployeeDirectoryInterface.sol";
import "./Owned.sol";

contract EmployeeDirectory is Owned, EmployeeDirectoryInterface {

    struct Employee {
      address[] allowedTokens;
      uint yearlyUSDSalary;
      uint index;
      uint lastAllocationDate;
      uint lastPayDate;
      bool employed;
    }
    
    mapping(address => Employee) internal employees;
    address[] internal employeeIndex;

    modifier onlyEmployee {
        require(employees[msg.sender].employed);
        _;
    }
    
    function addEmployee(address employeeAddress, address[] allowedTokens, uint initialYearlyUSDSalary)
        onlyOwner
        public
        returns (bool success) {
            require(employeeAddress != address(0));
            require(initialYearlyUSDSalary > 0);

            employees[employeeAddress].allowedTokens = allowedTokens;
            employees[employeeAddress].yearlyUSDSalary = initialYearlyUSDSalary;
            employees[employeeAddress].index = employeeIndex.push(employeeAddress)-1;
            employees[employeeAddress].employed = true;

            LogNewEmployee(msg.sender, employeeAddress, allowedTokens, initialYearlyUSDSalary);
            return true;
    }

    function setEmployeeSalary(address employeeAddress, uint yearlyUSDSalary) 
        onlyOwner
        public
        returns (bool success) {
            require(employeeAddress != address(0));
            require(yearlyUSDSalary > 0);
            require(employees[employeeAddress].yearlyUSDSalary != yearlyUSDSalary);

            employees[employeeAddress].yearlyUSDSalary = yearlyUSDSalary;

            LogUpdatedEmployeeSalary(msg.sender, employeeAddress, yearlyUSDSalary);
            return true;
    }

    function removeEmployee(address employeeAddress) 
        onlyOwner
        public 
        returns (bool success) { 
            require(employeeAddress != address(0));
            require(employees[employeeAddress].employed);

            employees[employeeAddress].employed = false;
            uint rowToDelete = employees[employeeAddress].index;
            address keyToMove = employeeIndex[employeeIndex.length-1];
            employeeIndex[rowToDelete] = keyToMove;
            employees[keyToMove].index = rowToDelete; 
            employeeIndex.length--;

            LogRemoveEmployee(msg.sender, employeeAddress);
            return true;
        }
      
    function getEmployeeCount() 
        constant
        public
        returns (uint count) { 
            return employeeIndex.length;
    }

    function getEmployee(uint employeeId) 
        constant 
        public
        returns (address employeeAddress) {
            return employeeIndex[employeeId]; // Return all other important info 
    }
}
