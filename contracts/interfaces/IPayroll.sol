pragma solidity ^0.4.15;

import "./IEmployeeDirectory.sol";

contract IPayroll is IEmployeeDirectory {

  event LogFundsAdded(address sender, uint amount);
  event LogAllocationDetermined(address sender, address[] tokens, uint[] distribution);
  event LogEmployeePayout(address sender, uint amount);
  event LogExchangeRateSet(address sender, address token, uint usdExchangeRate);
  
  function addFunds() payable returns (bool success);

  /* CONSTANTS */
  function calculatePayrollBurnrate() constant returns (uint monthlyBurnRate); 
  function calculatePayrollRunway() constant returns (uint months); 

  /* EMPLOYEE ONLY */
  function determineAllocation(address[] tokens, uint[] distribution) returns (bool success);
  function payday() returns (bool success); 

  /* ORACLE ONLY */
  //function setExchangeRate(address token, uint usdExchangeRate); // uses decimals from token
}