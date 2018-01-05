pragma solidity ^0.4.17;

import "./Interfaces.sol";
import "./Inbot.sol";

contract InScore is Score, InbotContract {
	mapping (address => uint) public scores;
	mapping (address => bool) public initialized;
	uint					  public scoreIncrement;
	uint					  public defaultScore;
	uint					  public maxScore;

	function InScore() public {
		// setting scoring increment/default in %
		scoreIncrement = WAD/10;
		defaultScore = WAD/2;
		maxScore = WAD/2;
	}

	function getScore(address _user) public view whenNotPaused returns (uint) {
		return initialized[_user] ? scores[_user] : defaultScore;
	}

	function setScore(address _user, uint _score) public onlyAdmin whenNotPaused {
		initialized[_user] = true;	
		scores[_user] = _score;	
	}

	function setScoreIncrement(uint _scoreIncrement) public onlyAdmin whenNotPaused {
		scoreIncrement = _scoreIncrement;
	}

	function setDefaultScore(uint _defaultScore) public onlyAdmin whenNotPaused {
		defaultScore = _defaultScore;
	}

	function setMaxScore(uint _maxScore) public onlyAdmin whenNotPaused {
		maxScore = _maxScore;
	}

	function scoreDown(address _user) public onlyAdmin whenNotPaused returns (bool) {
		setScore(_user, max(0, getScore(_user) - scoreIncrement));

		return true;
	}

	function scoreUp(address _user) public onlyAdmin whenNotPaused returns (bool) {
		setScore(_user, min(maxScore, getScore(_user) + scoreIncrement));

		return true;
	}
}