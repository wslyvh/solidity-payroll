var Payroll = artifacts.require("./Payroll.sol");
var ExchangeRates = artifacts.require("./ExchangeRates.sol");

module.exports = function(deployer) {
  deployer.deploy(Payroll);
  deployer.deploy(ExchangeRates, {value: 50, gas: 3000000});
};
