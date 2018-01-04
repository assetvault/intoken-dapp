pragma solidity ^0.4.17;

import "zeppelin-solidity/contracts/lifecycle/Pausable.sol";
import "zeppelin-solidity/contracts/ownership/rbac/RBAC.sol";
import "zeppelin-solidity/contracts/token/StandardToken.sol";
import "zeppelin-solidity/contracts/token/MintableToken.sol";
import "./Interfaces.sol";

contract InbotProxy is RBAC, Pausable {
	StandardToken	token;
	MintableToken	share;
	Score 			score;
	Mediator 		mediator;

	function InbotProxy(
		address _token, 
		address _share, 
		address _score, 
		address _mediator
	) {
		token = StandardToken(_token);
		share = MintableToken(_share);
		score = Score(_score);
		mediator = Mediator(_mediator);
	}

	function setToken(address _token) onlyAdmin {
		token = StandardToken(_token);
	}

	function getToken() whenNotPaused returns (StandardToken) {
		return token;
	}

	function setShare(address _share) onlyAdmin {
		share = MintableToken(_share);
	}

	function getShare() whenNotPaused returns (MintableToken) {
		return share;
	}

	function setScore(address _score) onlyAdmin {
		score = Score(_score);
	}

	function getScore() whenNotPaused returns (Score) {
		return score;
	}

	function setMediator(address _mediator) onlyAdmin {
		mediator = Mediator(_mediator);
	}

	function getMediator() whenNotPaused returns (Mediator) {
		return mediator;
	}
}
