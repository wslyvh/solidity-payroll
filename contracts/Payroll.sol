pragma solidity ^0.4.15;

import "./interfaces/IPayroll.sol";
import "./EmployeeDirectory.sol";
import "./ExchangeRates.sol";

contract Payroll is EmployeeDirectory, ExchangeRates, IPayroll {
    
    uint private fundsAvailableUSD;

    function Payroll() payable {
        
    }

    function addFunds() 
        payable
        public
        returns (bool success) {
            require(msg.value > 0); 
            fundsAvailableUSD += msg.value * getDefaultExchangeRate(); // TODO: funding with other tokens

            LogFundsAdded(msg.sender, msg.value);
            return true;
        }

    function payday()
        onlyEmployee
        public
        returns (bool success) { 
            require(getDefaultExchangeRate() > 0);
            require(employees[msg.sender].contractEndDate > block.timestamp);
            require(employees[msg.sender].lastPayDate < block.timestamp); // (block.timestamp + 1 month)

            uint monthlySalary = (employees[msg.sender].yearlyUSDSalary / 12) / getDefaultExchangeRate();
            // Divide on token/allocation(s)

            employees[msg.sender].lastPayDate = block.timestamp;
            msg.sender.transfer(monthlySalary);

            LogEmployeePayout(msg.sender, monthlySalary);
            return true;
        }

    function calculatePayrollBurnrate() 
        constant
        public
        returns (uint monthlyBurnRate) {
            uint salaries = 0;
            for (uint i = 0; i < employeeIndex.length; i++) {
            salaries += employees[employeeIndex[i]].yearlyUSDSalary / 12;
            }
            return salaries;
        } 

    function calculatePayrollRunway() 
        constant
        public
        returns (uint months) {
            return fundsAvailableUSD / calculatePayrollBurnrate();
        }
}