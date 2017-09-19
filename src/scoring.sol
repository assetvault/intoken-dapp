pragma solidity ^0.4.16;

import "ds-stop/stop.sol";
import "ds-math/math.sol";
import "./interfaces.sol";

contract TrustScoring is Scoring, DSStop, DSMath {
	mapping (address => uint) _scores;
	uint					  _scoreIncrement;

	function TrustScoring() {
		_scoreIncrement = 10;
	}

	function getScore(address user) stoppable returns (uint score) {
		return _scores[user];
	}

	function setScore(address user, uint score) auth stoppable note {
		_scores[user] = score;	
	}

	function setScoreIncrement(uint scoreIncrement) auth stoppable note {
		_scoreIncrement = scoreIncrement;
	}

	function scoreDown(address user) auth stoppable note returns (bool res) {
		_scores[user] = max(0, sub(_scores[user], _scoreIncrement));

		return true;
	}

	function scoreUp(address user) auth stoppable note returns (bool res) {
		_scores[user] = min(200, add(_scores[user], _scoreIncrement));

		return true;
	}
}