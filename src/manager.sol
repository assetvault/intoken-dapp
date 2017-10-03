pragma solidity ^0.4.16;

import "ds-stop/stop.sol";
import "ds-math/math.sol";
import "./interfaces.sol";
import "./proxy.sol";

contract TrustShareManagerEvents {
    event IncomeEscrowed(address indexed vendor, uint totalTokens, bool success);
    event SharesAllocated(address indexed vendor, address indexed ambassador, uint shares, bool success);
    event SharesDistributed(address indexed vendor, uint totalShares, uint sharePrice, bool success);	
}

contract TrustShareManager is ShareManager, TrustShareManagerEvents, DSStop, DSMath {
	TrustProxy                    			   	   _proxy;
	mapping (address => uint)				   	   _escrows;
	mapping (address => address[])				   _keys;
	mapping (address => mapping (address => uint)) _shares;

	modifier proxyExists() {
        require(_proxy != address(0x0));
        _;
    }

    function setProxy(address proxy) auth note {
        _proxy = TrustProxy(proxy);
    }

    function getShare(address vendor, address ambassador)
	    stoppable 
	    constant 
	    returns (uint share) 
    {
    	return _shares[vendor][ambassador];
    }

    function getEscrow(address vendor)
    	stoppable 
    	constant 
    	returns (uint share) 
    {
    	return _escrows[vendor];
    }

	function allocate(address vendor, address ambassador, uint shares)
		auth 
		stoppable
		note
		returns (bool res)
	{
		_shares[vendor][ambassador] = shares;
		_keys[vendor].push(ambassador);

		SharesAllocated(vendor, ambassador, shares, true);

		return true;
	}

	function escrow(address vendor, uint8 shareType, uint amount)
		auth 
		stoppable
		note
		proxyExists
		returns (bool res)
	{
		uint totalTokens = _proxy.getPricing().priceShare(shareType, amount);

		DSToken token = _proxy.getToken(); 
		token.mint(uint128(totalTokens));

		uint oneHalf = div(totalTokens, 2);

		_escrows[vendor] = add(_escrows[vendor], sub(totalTokens, oneHalf));
		res = token.transfer(token.owner(), oneHalf);

		IncomeEscrowed(vendor, totalTokens, res);
	}

	function distribute(address vendor, uint8 shareType, uint amount)
		auth 
		stoppable
		note
		proxyExists
		returns (bool res)
	{
		// figuring out the share pricing
		uint totalTokens = _proxy.getPricing().priceShare(shareType, amount);
		// performing trusted mint op
		_proxy.getToken().mint(uint128(totalTokens));
		// adding a total amount of accumulated escrows
		totalTokens = add(totalTokens, _escrows[vendor]);
		// zeroing escrows to avoid double-spending
		_escrows[vendor] = 0; 

		uint totalShares = 0;
		uint ambassadorShares = 0;
		address ambassador = address(0x0);
		res = true; uint sharePrice = 0;

		for(uint i = 0; i<_keys[vendor].length; i++) {
			ambassador = _keys[vendor][i];
			ambassadorShares = _shares[vendor][ambassador];
			totalShares = add(totalShares, ambassadorShares);
		}

		if (totalShares > 0) {
			sharePrice = div(totalTokens, totalShares);
			// allocating Trust Tokens according to shares
			for(i = 0; i<_keys[vendor].length; i++) {
				ambassador = _keys[vendor][i];
				ambassadorShares = _shares[vendor][ambassador];
				res = res && _proxy.getToken().approve(ambassador, mul(sharePrice, ambassadorShares));
			}			
		}

		SharesDistributed(vendor, totalShares, sharePrice, res);
	}
}