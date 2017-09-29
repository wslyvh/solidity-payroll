pragma solidity ^0.4.15;

import "./libraries/usingOraclize.sol";
import "./Owned.sol";

contract ExchangeRates is Owned, usingOraclize {

    event LogOraclizeEvent(string description, uint value);
    event LogNewTicker(bytes32 ticker);
    event LogExchangeRateUpdate(bytes32 ticker, uint value, uint timestamp);

    struct Pricefeed {
        string query;
        uint value;
        uint lastUpdated;
        bool active;
    }

    mapping(bytes32 => Pricefeed) tickers;
    mapping(bytes32 => bytes32) validCallbacks;

    function ExchangeRates() payable {
        OAR = OraclizeAddrResolverI(0x5B9be6B243eD1dAA4B68332A20C0d3De9d25D902);
        
        bytes32 id = bytes32("ETHUSD");
        tickers[id].query = "json(https://api.kraken.com/0/public/Ticker?pair=ETHUSD).result.XETHZUSD.c.0";

        //updateExchangeRate(id);
    }

    function addOrUpdateTicker(bytes32 ticker, string query, bool execute)
        onlyOwner
        public
        returns (bool success) {
            require(ticker.length > 0);
            require(bytes(tickers[ticker].query).length > 0);

            tickers[ticker].query = query;
            tickers[ticker].active = true;
            if (execute) { 
                updateExchangeRate(ticker);
            }

            LogNewTicker(ticker);
            return true;
        }
        
    function getTicker(bytes32 ticker) 
        constant
        public
        returns (uint value, uint lastUpdated) { 
            return (tickers[ticker].value, tickers[ticker].lastUpdated);
    }

    function getDefaultExchangeRate() 
        constant 
        public 
        returns (uint value) {
            return tickers[bytes32("ETHUSD")].value;
        }

    function updateExchangeRate(bytes32 ticker) {
        require(ticker.length > 0);
        require(tickers[ticker].active);
        require(bytes(tickers[ticker].query).length > 0);

        uint oraclizeFee = oraclize_getPrice("URL");
        if (oraclizeFee > this.balance) {
            LogOraclizeEvent("Oraclize query was NOT sent, please add some ETH to cover for the query fee.", oraclizeFee);
        } else {
            bytes32 queryId = oraclize_query("URL", tickers[ticker].query);
            validCallbacks[queryId] = ticker;
        }
    }

    function __callback(bytes32 myid, string result) {
        require(msg.sender == oraclize_cbAddress());
        require(tickers[validCallbacks[myid]].active);
        
        var value = parseInt(result);
        tickers[validCallbacks[myid]].value = value;
        tickers[validCallbacks[myid]].lastUpdated = block.timestamp;
        delete validCallbacks[myid];

        LogExchangeRateUpdate(validCallbacks[myid], value, block.timestamp);
    }
}