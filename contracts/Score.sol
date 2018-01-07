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
		// setting scoring increment/default IN%
		scoreIncrement = WAD.div(10);
		defaultScore = WAD.div(2);
		maxScore = WAD.mul(2);
	}

	/**
	* @dev Gets InScore (IN%) for a specified user address.
	* @param _user 	The _user address.
	* @return InScore (IN%).
	*/
	function getScore(address _user) public view whenNotPaused returns (uint) {
		return initialized[_user] ? scores[_user] : defaultScore;
	}

	/**
	* @dev Sets InScore (IN%) for a specified user address.
	* @param _user 	The _user address.
	* @param _score InScore (IN%).
	*/
	function setScore(address _user, uint _score) public onlyAdmin whenNotPaused {
		initialized[_user] = true;	
		scores[_user] = _score;	
	}

	/**
	* @dev Sets InScore's (IN%) incremental update step.
	* @param _scoreIncrement	Incremental update step.
	*/
	function setScoreIncrement(uint _scoreIncrement) public onlyAdmin whenNotPaused {
		scoreIncrement = _scoreIncrement;
	}

	/**
	* @dev Sets InScore's (IN%) default score for new users.
	* @param _defaultScore	Default IN%.
	*/
	function setDefaultScore(uint _defaultScore) public onlyAdmin whenNotPaused {
		defaultScore = _defaultScore;
	}

	/**
	* @dev Sets InScore's (IN%) maximum score.
	* @param _maxScore	Maximum IN%.
	*/
	function setMaxScore(uint _maxScore) public onlyAdmin whenNotPaused {
		maxScore = _maxScore;
	}

	/**
	* @dev Decrements IN% for a specified user address.
	* @param _user 	The _user address.
	* @return A boolean that indicates if the operation was successful.
	*/
	function scoreDown(address _user) public onlyAdmin whenNotPaused returns (bool) {
		uint score = getScore(_user);

		require(score > 0);
		setScore(_user, score.sub(scoreIncrement));

		return true;
	}

	/**
	* @dev Increments IN% for a specified user address.
	* @param _user 	The _user address.
	* @return A boolean that indicates if the operation was successful.
	*/
	function scoreUp(address _user) public onlyAdmin whenNotPaused returns (bool) {
		setScore(_user, min(maxScore, getScore(_user).add(scoreIncrement)));

		return true;
	}
}