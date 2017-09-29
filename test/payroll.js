const expectedExceptionPromise = require("../utils/expectedException.js");
web3.eth.getTransactionReceiptMined = require("../utils/getTransactionReceiptMined.js");
Promise = require("bluebird");
Promise.allNamed = require("../utils/sequentialPromiseNamed.js");
const randomIntIn = require("../utils/randomIntIn.js");
const toBytes32 = require("../utils/toBytes32.js");

if (typeof web3.eth.getAccountsPromise === "undefined") {
    Promise.promisifyAll(web3.eth, { suffix: "Promise" });
}

const Payroll = artifacts.require("./Payroll.sol");

contract('Payroll', function(accounts) {

    let payroll, owner;

    before("should prepare", function() {
        console.log("Checking available accounts..");
        assert.isAtLeast(accounts.length, 1);
        owner = accounts[0];

        return web3.eth.getBalancePromise(owner)
            .then(balance => assert.isAtLeast(web3.fromWei(balance).toNumber(), 50));
    });

    beforeEach("should deploy a new Contract", function() {
        console.log("Deploying new contract..");
        
        return Payroll.new({ from: owner, value: 10, gas:3000000 })
            .then(instance => payroll = instance)
    });

    describe("Owner functions", function() {
        
        it("should update exchangeRate", function() {
            console.log("Updating exchange rate..");
            
            return payroll.setExchangeRate({from: owner, value: 10, gas: 3000000})
                .then(tx => { 
                    console.log(tx);
                    assert.strictEqual(tx.receipt.logs.length, 5);
                })
        });
                
    });
    
    describe("Update", function() {
        
        it("should update exchangeRate", function() {
            console.log("Updating exchange rate..");
            
            return payroll.setExchangeRate({from: owner, value: 10, gas: 3000000})
                .then(tx => { 
                    console.log(tx);
                    assert.strictEqual(tx.receipt.logs.length, 5);
                })
        });
                
    });
});