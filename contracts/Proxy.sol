pragma solidity ^0.4.17;

import "zeppelin-solidity/contracts/lifecycle/Pausable.sol";
import "zeppelin-solidity/contracts/ownership/rbac/RBAC.sol";
import "zeppelin-solidity/contracts/token/MintableToken.sol";
import "./Interfaces.sol";

contract InbotProxy is RBAC, Pausable {
	MintableToken	token;
	MintableToken	share;
	Score 			score;
	Gateway 		gateway;

	function InbotProxy(
		address _token, 
		address _share, 
		address _score, 
		address _gateway
	) public 
	{
		token = MintableToken(_token);
		share = MintableToken(_share);
		score = Score(_score);
		gateway = Gateway(_gateway);
	}

	function setToken(address _token) public onlyAdmin {
		token = MintableToken(_token);
	}

	function getToken() whenNotPaused public view returns (MintableToken) {
		return token;
	}

	function setShare(address _share) public onlyAdmin {
		share = MintableToken(_share);
	}

	function getShare() whenNotPaused public view returns (MintableToken) {
		return share;
	}

	function setScore(address _score) public onlyAdmin {
		score = Score(_score);
	}

	function getScore() public whenNotPaused view returns (Score) {
		return score;
	}

	function setGateway(address _gateway) public onlyAdmin {
		gateway = Gateway(_gateway);
	}

	function getgateway() whenNotPaused public view returns (Gateway) {
		return gateway;
	}
}
