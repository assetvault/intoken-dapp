pragma solidity ^0.4.16;

import "ds-token/token.sol";
import "ds-stop/stop.sol";
import "./interfaces.sol";

contract TrustProxy is DSStop {
	DSToken				_token;
	Pricing				_pricing;
	Scoring 			_scoring;
	UserInfo 			_userInfo;
	Mediator 			_mediator;
	ShareAllocation		_shareAllocation;

	function TrustProxy(
		address token, 
		address pricing, 
		address scoring, 
		address userInfo, 
		address mediator, 
		address shareAllocation
	) {
		_token = DSToken(token);
		_pricing = Pricing(pricing);
		_scoring = Scoring(scoring);
		_userInfo = UserInfo(userInfo);
		_mediator = Mediator(mediator);
		_shareAllocation = ShareAllocation(shareAllocation);
	}

	function setToken(address token) auth {
		_token = DSToken(token);
	}

	function getToken() stoppable returns (DSToken) {
		return _token;
	}

	function setPricing(address pricing) auth {
		_pricing = Pricing(pricing);
	}

	function getPricing() stoppable returns (Pricing) {
		return _pricing;
	}

	function setScoring(address scoring) auth {
		_scoring = Scoring(scoring);
	}

	function getScoring() stoppable returns (Scoring) {
		return _scoring;
	}

	function setUserInfo(address userInfo) auth {
		_userInfo = UserInfo(userInfo);
	}

	function getUserInfo() stoppable returns (UserInfo) {
		return _userInfo;
	}

	function setMediator(address mediator) auth {
		_mediator = Mediator(mediator);
	}

	function getMediator() stoppable returns (Mediator) {
		return _mediator;
	}

	function setShareAllocation(address shareAllocation) auth {
		_shareAllocation = ShareAllocation(shareAllocation);
	}

	function getShareAllocation() stoppable returns (ShareAllocation) {
		return _shareAllocation;
	}
}
