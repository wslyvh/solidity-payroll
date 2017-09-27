pragma solidity ^0.4.15;

import "./Owned.sol";
import "./libraries/oraclizeAPI.sol";
import "./interfaces/PayrollInterface.sol";

contract Payroll is Owned, PayrollInterface, usingOraclize {
    
    struct Employee {
      address[] allowedTokens;
      uint yearlyUSDSalary;
      uint index;
      uint lastAllocationDate;
      uint lastPayDate;
      bool employed;
    }

    mapping(address => Employee) private employees;
    address[] private employeeIndex;
    uint private fundsAvailableUSD;
    uint private exchangeRate;

    modifier onlyEmployee {
        require(employees[msg.sender].employed);
        _;
    }

    /* 
      Ctor
    */
    function Payroll() payable {
        setExchangeRate();
    }

    /* 
      OWNER (crud)
    */
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

  function addFunds() 
    payable
    public
    returns (bool success) {
      require(msg.value > 0); 
      fundsAvailableUSD += msg.value * exchangeRate;

      LogFundsAdded(msg.sender, msg.value);
      return true;
    }

  //function scapeHatch(); // ?

  /* 
    EMPLOYEE 
  */
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

  function payday()
    onlyEmployee
    public
    returns (bool success) { 
      require(exchangeRate > 0);
      require(employees[msg.sender].lastPayDate < block.timestamp); // (block.timestamp + 1 month)

      uint monthlySalary = (employees[msg.sender].yearlyUSDSalary / 12) / exchangeRate;
      // Divide on token/allocation(s)

      employees[msg.sender].lastPayDate = block.timestamp;
      msg.sender.transfer(monthlySalary);

      LogEmployeePayout(msg.sender, monthlySalary);
      return true;
    }

  /*
    CONSTANTS
  */
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

  /* 
    ORACLE 
  */

  //function setExchangeRate(address token, uint usdExchangeRate); // uses decimals from token
  function __callback(string result) {
    require(msg.sender != oraclize_cbAddress());

    exchangeRate = parseUint(result);
  }

  function setExchangeRate() payable {
    if (oraclize_getPrice("URL") > this.balance) {
        newOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
    } else {
        newOraclizeQuery("Oraclize query was sent, standing by for the answer..");
        oraclize_query(60, "URL", "json(https://api.coinmarketcap.com/v1/ticker/ethereum)[0].price_usd");
    }
  }

  event newOraclizeQuery(string description);
  
  function parseUint(string s) 
    private
    constant 
    returns (uint result) {
      bytes memory b = bytes(s);
      uint i;
      result = 0;
      for (i = 0; i < b.length; i++) {
          uint c = uint(b[i]);
          if (c >= 48 && c <= 57) {
              result = result * 10 + (c - 48);
          }
      }
  }
}