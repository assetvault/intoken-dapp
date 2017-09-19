pragma solidity ^0.4.16;

import "ds-stop/stop.sol";
import "ds-math/math.sol";
import "./interfaces.sol";
import "./proxy.sol";

contract TrustShareManager is ShareManager, DSStop, DSMath {
	TrustProxy                    			   	   _proxy;
	mapping (address => address[])				   _keys;
	mapping (address => mapping (address => uint)) _shares;

	modifier proxyExists() {
        require(_proxy != address(0x0));
        _;
    }

    event Allocated(address indexed vendor, address indexed ambassador, uint shares, bool success);
    event Distributed(address indexed vendor, uint totalShares, uint sharePrice, bool success);

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

		Allocated(vendor, ambassador, shares, true);

		return true;
	}

	function distribute(address vendor, uint8 shareType, uint amount) 
		auth 
		stoppable
		note
		proxyExists
		returns (bool res)
	{
		uint totalTokens = _proxy.getPricing().priceShare(shareType, amount);
		require(_proxy.getToken().balanceOf(msg.sender) >= totalTokens);

		uint totalShares = 0;
		address ambassador = address(0x0);

		for(uint i = 1; i<_keys[vendor].length; i++) {
			ambassador = _keys[vendor][i];
			totalShares = add(totalShares, _shares[vendor][ambassador]);
		}

		res = true; uint shares = 0;
		uint sharePrice = div(totalTokens, totalShares);

		for(i = 1; i<_keys[vendor].length; i++) {
			ambassador = _keys[vendor][i];
			shares = _shares[vendor][ambassador];

			res = res && _proxy.getToken().approve(ambassador, mul(sharePrice, shares));
		}

		Distributed(vendor, totalShares, sharePrice, res);
	}
}