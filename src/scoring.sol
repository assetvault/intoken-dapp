pragma solidity ^0.4.16;

import "ds-stop/stop.sol";
import "ds-math/math.sol";
import "./interfaces.sol";

contract TrustScoring is Scoring, DSStop, DSMath {
	mapping (address => uint) _scores;
	mapping (address => bool) _initialized;
	uint					  _scoreIncrement;
	uint					  _defaultScore;

	function TrustScoring() {
		// setting scoring increment/default in %
		_scoreIncrement = 10;
		_defaultScore = 50;
	}

	function getScore(address user) stoppable constant returns (uint score) {
		return _initialized[user] ? _scores[user] : _defaultScore;
	}

	function setScore(address user, uint score) auth stoppable note {
		_initialized[user] = true;	
		_scores[user] = score;	
	}

	function setScoreIncrement(uint scoreIncrement) auth stoppable note {
		_scoreIncrement = scoreIncrement;
	}

	function setDefaultScore(uint defaultScore) auth stoppable note {
		_defaultScore = defaultScore;
	}

	function scoreDown(address user) auth stoppable note returns (bool res) {
		setScore(user, max(0, sub(getScore(user), _scoreIncrement)));

		return true;
	}

	function scoreUp(address user) auth stoppable note returns (bool res) {
		setScore(user, min(200, add(getScore(user), _scoreIncrement)));

		return true;
	}
}