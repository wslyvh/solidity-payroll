pragma solidity ^0.4.15;

import "./OwnedInterface.sol";

contract PayrollInterface is OwnedInterface {

  event LogNewEmployee(address sender, address indexed employeeAddress, address[] allowedTokens, uint initialYearlyUSDSalary);
  event LogUpdatedEmployeeSalary(address sender, address indexed employeeAddress, uint initialYearlyUSDSalary);
  event LogRemoveEmployee(address sender, address indexed employeeAddress);
  event LogFundsAdded(address sender, uint amount);
  event LogAllocationDetermined(address sender, address[] tokens, uint[] distribution);
  event LogEmployeePayout(address sender, uint amount);
  event LogExchangeRateSet(address sender, address token, uint usdExchangeRate);
  
  /* OWNER ONLY */
  function addEmployee(address employeeAddress, address[] allowedTokens, uint initialYearlyUSDSalary) returns (bool success);
  function setEmployeeSalary(address employeeAddress, uint yearlyUSDSalary) returns (bool success);
  function removeEmployee(address employeeAddress) returns (bool success);

  function addFunds() payable returns (bool success);

  /* CONSTANTS */
  function getEmployeeCount() constant returns (uint count);
  function getEmployee(uint employeeId) constant returns (address employeeAddress); 
  function calculatePayrollBurnrate() constant returns (uint monthlyBurnRate); 
  function calculatePayrollRunway() constant returns (uint months); 

  /* EMPLOYEE ONLY */
  function determineAllocation(address[] tokens, uint[] distribution) returns (bool success);
  function payday() returns (bool success); 

  /* ORACLE ONLY */
  //function setExchangeRate(address token, uint usdExchangeRate); // uses decimals from token
}