pragma solidity ^0.4.17;

import "zeppelin-solidity/contracts/lifecycle/Pausable.sol";
import "zeppelin-solidity/contracts/ownership/rbac/RBAC.sol";
import "zeppelin-solidity/contracts/token/MintableToken.sol";
import "./Interfaces.sol";

contract InbotProxy is RBAC, Pausable {
	MintableToken	token;
	MintableToken	share;
	Score 			score;
	Mediator 		mediator;

	function InbotProxy(
		address _token, 
		address _share, 
		address _score, 
		address _mediator
	) public 
	{
		token = MintableToken(_token);
		share = MintableToken(_share);
		score = Score(_score);
		mediator = Mediator(_mediator);
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

	function setMediator(address _mediator) public onlyAdmin {
		mediator = Mediator(_mediator);
	}

	function getMediator() whenNotPaused public view returns (Mediator) {
		return mediator;
	}
}
