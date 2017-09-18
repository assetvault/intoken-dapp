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

	enum CorpSize {
		ANY,
		Small, 
		Medium, 
		Large
	}

	enum CorpPosition {
		ANY,
		Manager, 
		Director, 
		VicePresident,
		CXO
	}

    TrustProxy                    				_proxy;
	uint256										_tokenPrice;
    mapping (uint => uint)  					_sharePricing;
    mapping (uint => mapping (uint => uint256)) _introPricing;

    function TrustPricing(uint tokenPrice) {
    	_tokenPrice = tokenPrice;
    	// setting pricing per share typr
    	_sharePricing[uint(ShareType.Fiat)] = 95;
    	_sharePricing[uint(ShareType.MajorStocks)] = 90;
    	_sharePricing[uint(ShareType.BTC)] = 85;
    	_sharePricing[uint(ShareType.ETH)] = 85;
    	_sharePricing[uint(ShareType.MinorStocks)] = 75;
    	_sharePricing[uint(ShareType.Crypto)] = 70;
    	_sharePricing[uint(ShareType.StartupStocks)] = 50;
    	//setting pricing per intro configuration
    	_introPricing[uint(CorpSize.ANY)][uint(CorpPosition.ANY)] = 40;
    	_introPricing[uint(CorpSize.Small)][uint(CorpPosition.Manager)] = 40;
    	_introPricing[uint(CorpSize.Small)][uint(CorpPosition.Director)] = 60;
    	_introPricing[uint(CorpSize.Small)][uint(CorpPosition.VicePresident)] = 80;
    	_introPricing[uint(CorpSize.Small)][uint(CorpPosition.CXO)] = 100;
    	_introPricing[uint(CorpSize.Medium)][uint(CorpPosition.Manager)] = 80;
    	_introPricing[uint(CorpSize.Medium)][uint(CorpPosition.Director)] = 120;
    	_introPricing[uint(CorpSize.Medium)][uint(CorpPosition.VicePresident)] = 160;
    	_introPricing[uint(CorpSize.Medium)][uint(CorpPosition.CXO)] = 200;
    	_introPricing[uint(CorpSize.Large)][uint(CorpPosition.Manager)] = 160;
    	_introPricing[uint(CorpSize.Large)][uint(CorpPosition.Director)] = 240;
    	_introPricing[uint(CorpSize.Large)][uint(CorpPosition.VicePresident)] = 320;
    	_introPricing[uint(CorpSize.Large)][uint(CorpPosition.CXO)] = 400;
    }

    modifier proxyExists() {
        require(_proxy != address(0x0));
        _;
    }

    function setProxy(address proxy) auth note {
        _proxy = TrustProxy(proxy);
    }

    function setTokenPrice(uint tokenPrice) auth note {
        _tokenPrice = tokenPrice;
    }

    function setSharePricing(uint shareType, uint pricing) auth note {
        _sharePricing[shareType] = pricing;
    }

    function setIntroPricing(uint corpSize, uint corpPosition, uint pricing) auth note {
        _introPricing[corpSize][corpPosition] = pricing;
    }

    function priceShare(uint shareType, uint amount) stoppable returns (uint tokens) {
    	uint mintedAmount = div(mul(amount, _sharePricing[shareType]), 100);
    	require((tokens = div(mintedAmount, _tokenPrice)) > 0); 
    }

    function priceIntro(address ambassador) stoppable proxyExists returns (uint tokens) {
    	uint corpSize = _proxy.getUserInfo().getInfo(ambassador, "corp_size");
    	uint corpPosition = _proxy.getUserInfo().getInfo(ambassador, "corp_position");

    	return _introPricing[corpSize][corpPosition];
    }
}