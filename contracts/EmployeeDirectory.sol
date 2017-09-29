pragma solidity ^0.4.15;

import "./interfaces/IEmployeeDirectory.sol";
import "./Owned.sol";

contract EmployeeDirectory is Owned, IEmployeeDirectory {

    function addEmployee(address employeeAddress, address[] allowedTokens, uint initialYearlyUSDSalary, uint contractEndDate)
        onlyOwner
        public
        returns (bool success) {
            require(employeeAddress != address(0));
            require(initialYearlyUSDSalary > 0);

            employees[employeeAddress].allowedTokens = allowedTokens;
            employees[employeeAddress].yearlyUSDSalary = initialYearlyUSDSalary;
            employees[employeeAddress].contractEndDate = contractEndDate;
            employees[employeeAddress].index = employeeIndex.push(employeeAddress)-1;
            employees[employeeAddress].employed = true;

            LogNewEmployee(msg.sender, employeeAddress, allowedTokens, initialYearlyUSDSalary, contractEndDate);
            return true;
    }

    function updateEmployee(address employeeAddress, uint yearlyUSDSalary, uint contractEndDate) 
        onlyOwner
        public
        returns (bool success) {
            require(employeeAddress != address(0));
            require(yearlyUSDSalary > 0);
            require(employees[employeeAddress].yearlyUSDSalary != yearlyUSDSalary);

            employees[employeeAddress].yearlyUSDSalary = yearlyUSDSalary;
            employees[employeeAddress].contractEndDate = contractEndDate;

            LogUpdatedEmployee(msg.sender, employeeAddress, yearlyUSDSalary, contractEndDate);
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

    function determineAllocation(address[] tokens, uint[] distribution) 
        onlyEmployee
        public
        returns (bool success) {
            require(employees[msg.sender].lastPayDate < block.timestamp); // (block.timestamp + 6 months)

            // Re-allocation
            employees[msg.sender].lastPayDate = block.timestamp;

            LogAllocationDetermined(msg.sender, tokens, distribution);
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
        returns (address employeeAddress, address[] allowedTokens, uint yearlyUSDSalary, uint lastAllocationDate, uint lastPayDate, uint contractEndDate, bool employed) {

            return (employeeIndex[employeeId],
                    employees[employeeAddress].allowedTokens,
                    employees[employeeAddress].yearlyUSDSalary,
                    employees[employeeAddress].lastAllocationDate,
                    employees[employeeAddress].lastPayDate,
                    employees[employeeAddress].contractEndDate,
                    employees[employeeAddress].employed);
    }
}