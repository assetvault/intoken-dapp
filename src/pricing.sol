pragma solidity ^0.4.16;

import "ds-stop/stop.sol";
import "ds-math/math.sol";
import "./interfaces.sol";
import "./proxy.sol";

contract TrustPricing is Pricing, DSStop, DSMath {
	enum ShareType {
		Fiat,
		ETH,
		BTC,
		MajorStocks,
		MinorStocks,
		StartupStocks,
		Crypto
	}

    TrustProxy                    			   _proxy;
    uint                                       _tokenPrice;
    mapping (uint8 => uint)  			       _sharePricing;

    function TrustPricing() {
        _tokenPrice = WAD / 10;
        // setting pricing in % per share type
         uint sharePrice = WAD / 100;
    	_sharePricing[uint8(ShareType.Fiat)] = mul(95, sharePrice);
    	_sharePricing[uint8(ShareType.MajorStocks)] = mul(90, sharePrice);
    	_sharePricing[uint8(ShareType.BTC)] = mul(85, sharePrice);
    	_sharePricing[uint8(ShareType.ETH)] = mul(85, sharePrice);
    	_sharePricing[uint8(ShareType.MinorStocks)] = mul(75, sharePrice);
    	_sharePricing[uint8(ShareType.Crypto)] = mul(70, sharePrice);
    	_sharePricing[uint8(ShareType.StartupStocks)] = mul(50, sharePrice);
    }

    modifier proxyExists() {
        require(_proxy != address(0x0));
        _;
    }

    function setProxy(address proxy) auth note {
        _proxy = TrustProxy(proxy);
    }

    function getTokenPrice() stoppable constant returns (uint price) {
        return _tokenPrice;
    }

    function setTokenPrice(uint tokenPrice) auth stoppable note {
        _tokenPrice = tokenPrice;
    }

    function getSharePricing(uint8 shareType) stoppable constant returns (uint pricing) {
        return _sharePricing[shareType];
    }

    function setSharePricing(uint8 shareType, uint pricing) auth stoppable note {
        _sharePricing[shareType] = pricing;
    }

    function priceShare(uint8 shareType, uint amount) stoppable returns (uint tokens) {
        uint wadAmount = mul(WAD, amount);
    	uint mintedAmount = wdiv(wadAmount, _tokenPrice);

    	require((tokens = wmul(mintedAmount, _sharePricing[shareType])) > 0); 
    }

    function priceIntro(address ambassador) stoppable proxyExists returns (uint tokens) {
        uint score = _proxy.getScoring().getScore(ambassador);

    	require((tokens = mul(WAD, score)) > 0);
    }
}