pragma solidity ^0.4.17;

import "./Interfaces.sol";
import "./Inbot.sol";

contract InScore is Score, InbotContract {
	mapping (address => uint) public scores;
	mapping (address => bool) public initialized;
	uint					  public scoreIncrement;
	uint					  public defaultScore;
	uint					  public maxScore;

	function InScore() {
		// setting scoring increment/default in %
		scoreIncrement = WAD/10;
		defaultScore = WAD/2;
		maxScore = WAD/2;
	}

	function getScore(address _user) whenNotPaused constant returns (uint) {
		return initialized[_user] ? scores[_user] : defaultScore;
	}

	function setScore(address _user, uint _score) onlyAdmin whenNotPaused {
		initialized[_user] = true;	
		scores[_user] = _score;	
	}

	function setScoreIncrement(uint _scoreIncrement) onlyAdmin whenNotPaused {
		scoreIncrement = _scoreIncrement;
	}

	function setDefaultScore(uint _defaultScore) onlyAdmin whenNotPaused {
		defaultScore = _defaultScore;
	}

	function setMaxScore(uint _maxScore) onlyAdmin whenNotPaused {
		maxScore = _maxScore;
	}

	function scoreDown(address _user) onlyAdmin whenNotPaused returns (bool) {
		setScore(_user, max(0, getScore(_user) - scoreIncrement));

		return true;
	}

	function scoreUp(address _user) onlyAdmin whenNotPaused returns (bool) {
		setScore(_user, min(maxScore, getScore(_user) + scoreIncrement));

		return true;
	}
}