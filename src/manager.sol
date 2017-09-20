pragma solidity ^0.4.16;

import "ds-stop/stop.sol";
import "ds-math/math.sol";
import "./interfaces.sol";
import "./proxy.sol";

contract TrustShareManager is ShareManager, DSStop, DSMath {
	TrustProxy                    			   	   _proxy;
	mapping (address => uint)				   	   _escrows;
	mapping (address => address[])				   _keys;
	mapping (address => mapping (address => uint)) _shares;

	modifier proxyExists() {
        require(_proxy != address(0x0));
        _;
    }

    event IncomeAllocated(address indexed vendor, uint totalTokens, bool success);
    event SharesAllocated(address indexed vendor, address indexed ambassador, uint shares, bool success);
    event SharesDistributed(address indexed vendor, uint totalShares, uint sharePrice, bool success);

    function setProxy(address proxy) auth note {
        _proxy = TrustProxy(proxy);
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

	function allocate(address vendor, uint8 shareType, uint amount)
		auth 
		stoppable
		note
		proxyExists
		returns (bool res)
	{
		uint totalTokens = _proxy.getPricing().priceShare(shareType, amount);

		DSToken token = _proxy.getToken(); 
		token.mint(uint128(totalTokens));

		_escrows[vendor] = add(_escrows[vendor], div(totalTokens, 4));

		res = token.transfer(token.owner(), div(totalTokens, 4));
		res = res && token.approve(vendor, div(totalTokens, 2));

		IncomeAllocated(vendor, totalTokens, res);
	}

	function distribute(address vendor, uint8 shareType, uint amount)
		auth 
		stoppable
		note
		proxyExists
		returns (bool res)
	{
		DSToken token = _proxy.getToken(); 
		// figuring out the share pricing and performing trusted mint op
		uint totalTokens = _proxy.getPricing().priceShare(shareType, amount);
		token.mint(uint128(totalTokens));
		// adding a total amount of accumulated escrows
		totalTokens = totalTokens + _escrows[vendor];

		uint totalShares = 0;
		uint ambassadorShares = 0;
		address ambassador = address(0x0);

		for(uint i = 1; i<_keys[vendor].length; i++) {
			ambassador = _keys[vendor][i];
			ambassadorShares = _shares[vendor][ambassador];
			totalShares = add(totalShares, ambassadorShares);
		}

		res = true; uint sharePrice = div(totalTokens, totalShares);

		for(i = 1; i<_keys[vendor].length; i++) {
			ambassador = _keys[vendor][i];
			ambassadorShares = _shares[vendor][ambassador];
			res = res && token.approve(ambassador, mul(sharePrice, ambassadorShares));
		}

		SharesDistributed(vendor, totalShares, sharePrice, res);
	}
}