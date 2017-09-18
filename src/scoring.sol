pragma solidity ^0.4.16;

import "ds-stop/stop.sol";
import "ds-math/math.sol";
import "./interfaces.sol";

contract TrustScoring is Scoring, DSStop {
	mapping (address => uint) _scores;
	uint					  _scoreIncrement;

	function TrustScoring() {
		_score_inc = 10;
	}

	function getScore(address user, uint score) stoppable returns (uint score) {
		return _scores[user];
	}

	function setScore(address user, uint score) auth note {
		_scores[user] = score;	
	}

	function setScoreIncrement(uint scoreIncrement) auth note {
		_scoreIncrement = scoreIncrement;
	}

	function scoreDown(address user) returns (bool res) {
		_scores[user] = min(0, sub(_scores[user], _scoreIncrement))
	}

	function scoreUp(address user) returns (bool res) {
		_scores[user] = min(200, add(_scores[user], _scoreIncrement))
	}

}