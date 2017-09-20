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

    TrustProxy                    			   _proxy;
	uint								   	   _tokenPrice;
    mapping (uint8 => uint)  				   _sharePricing;
    mapping (uint8 => mapping (uint8 => uint)) _introPricing;

    function TrustPricing(uint8 tokenPrice) {
    	_tokenPrice = tokenPrice;
    	// setting pricing per share typr
    	_sharePricing[uint8(ShareType.Fiat)] = 95;
    	_sharePricing[uint8(ShareType.MajorStocks)] = 90;
    	_sharePricing[uint8(ShareType.BTC)] = 85;
    	_sharePricing[uint8(ShareType.ETH)] = 85;
    	_sharePricing[uint8(ShareType.MinorStocks)] = 75;
    	_sharePricing[uint8(ShareType.Crypto)] = 70;
    	_sharePricing[uint8(ShareType.StartupStocks)] = 50;
    	//setting pricing per intro configuration
    	_introPricing[uint8(CorpSize.ANY)][uint8(CorpPosition.ANY)] = 40;
    	_introPricing[uint8(CorpSize.ANY)][uint8(CorpPosition.Manager)] = 40;
    	_introPricing[uint8(CorpSize.ANY)][uint8(CorpPosition.Director)] = 60;
    	_introPricing[uint8(CorpSize.ANY)][uint8(CorpPosition.VicePresident)] = 80;
    	_introPricing[uint8(CorpSize.ANY)][uint8(CorpPosition.CXO)] = 100;
    	_introPricing[uint8(CorpSize.Small)][uint8(CorpPosition.ANY)] = 40;
    	_introPricing[uint8(CorpSize.Small)][uint8(CorpPosition.Manager)] = 40;
    	_introPricing[uint8(CorpSize.Small)][uint8(CorpPosition.Director)] = 60;
    	_introPricing[uint8(CorpSize.Small)][uint8(CorpPosition.VicePresident)] = 80;
    	_introPricing[uint8(CorpSize.Small)][uint8(CorpPosition.CXO)] = 100;
    	_introPricing[uint8(CorpSize.Medium)][uint8(CorpPosition.ANY)] = 80;
    	_introPricing[uint8(CorpSize.Medium)][uint8(CorpPosition.Manager)] = 80;
    	_introPricing[uint8(CorpSize.Medium)][uint8(CorpPosition.Director)] = 120;
    	_introPricing[uint8(CorpSize.Medium)][uint8(CorpPosition.VicePresident)] = 160;
    	_introPricing[uint8(CorpSize.Medium)][uint8(CorpPosition.CXO)] = 200;
    	_introPricing[uint8(CorpSize.Large)][uint8(CorpPosition.ANY)] = 160;
    	_introPricing[uint8(CorpSize.Large)][uint8(CorpPosition.Manager)] = 160;
    	_introPricing[uint8(CorpSize.Large)][uint8(CorpPosition.Director)] = 240;
    	_introPricing[uint8(CorpSize.Large)][uint8(CorpPosition.VicePresident)] = 320;
    	_introPricing[uint8(CorpSize.Large)][uint8(CorpPosition.CXO)] = 400;
    }

    modifier proxyExists() {
        require(_proxy != address(0x0));
        _;
    }

    function setProxy(address proxy) auth note {
        _proxy = TrustProxy(proxy);
    }

    function setTokenPrice(uint tokenPrice) auth stoppable note {
        _tokenPrice = tokenPrice;
    }

    function setSharePricing(uint8 shareType, uint pricing) auth stoppable note {
        _sharePricing[shareType] = pricing;
    }

    function setIntroPricing(uint8 corpSize, uint8 corpPosition, uint pricing) auth stoppable note {
        _introPricing[corpSize][corpPosition] = pricing;
    }

    function priceShare(uint8 shareType, uint amount) stoppable returns (uint tokens) {
    	uint mintedAmount = div(mul(amount, _sharePricing[shareType]), 100);
    	
    	require((tokens = div(mintedAmount, _tokenPrice)) > 0); 
    }

    function priceIntro(address ambassador) stoppable proxyExists returns (uint tokens) {
    	uint8 corpSize = uint8(_proxy.getUserInfo().getInfo(ambassador, "corp_size"));
    	uint8 corpPosition = uint8(_proxy.getUserInfo().getInfo(ambassador, "corp_position"));

    	require((tokens = mul(_introPricing[corpSize][corpPosition], _proxy.getScoring().getScore(ambassador))) > 0);
    }
}