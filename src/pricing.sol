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
    uint128                                    _tokenPrice;
    mapping (uint8 => uint128)  			   _sharePricing;

    function TrustPricing() {
        _tokenPrice = hdiv(WAD, uint128(10));
        // setting pricing in % per share type
         uint128 sharePrice = hdiv(WAD, uint128(100));
    	_sharePricing[uint8(ShareType.Fiat)] = hmul(uint128(95), sharePrice);
    	_sharePricing[uint8(ShareType.MajorStocks)] = hmul(uint128(90), sharePrice);
    	_sharePricing[uint8(ShareType.BTC)] = hmul(uint128(85), sharePrice);
    	_sharePricing[uint8(ShareType.ETH)] = hmul(uint128(85), sharePrice);
    	_sharePricing[uint8(ShareType.MinorStocks)] = hmul(uint128(75), sharePrice);
    	_sharePricing[uint8(ShareType.Crypto)] = hmul(uint128(70), sharePrice);
    	_sharePricing[uint8(ShareType.StartupStocks)] = hmul(uint128(50), sharePrice);
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

    function setTokenPrice(uint128 tokenPrice) auth stoppable note {
        _tokenPrice = tokenPrice;
    }

    function getSharePricing(uint8 shareType) stoppable constant returns (uint128 pricing) {
        return _sharePricing[shareType];
    }

    function setSharePricing(uint8 shareType, uint128 pricing) auth stoppable note {
        _sharePricing[shareType] = pricing;
    }

    function priceShare(uint8 shareType, uint amount) stoppable returns (uint tokens) {
        uint128 wadAmount = cast(mul(WAD, amount));
    	uint128 mintedAmount = wdiv(wadAmount, _tokenPrice);

    	require((tokens = wmul(mintedAmount, _sharePricing[shareType])) > 0); 
    }

    function priceIntro(address ambassador) stoppable proxyExists returns (uint tokens) {
        uint score = _proxy.getScoring().getScore(ambassador);

    	require((tokens = mul(WAD, score)) > 0);
    }
}