pragma solidity ^0.4.17;

interface Mediator {
	function open(uint _introId, uint _bid, uint _creationTime, string _hashedInfo) external;
	function accept(uint _introId, address _ambassador, uint _updateTime) external;
	function endorse(uint _introId, uint _updateTime) external;
	function dispute(uint _introId, uint _updateTime) external;
	function withdraw(uint _introId, uint _updateTime) external;
	function resolve(uint _introId, uint _updateTime, string _resolution, bool _isSpam) external;
}

interface Score {
	function setScore(address user, uint score);
	function getScore(address user) constant returns (uint score);
	function scoreDown(address user) returns (bool res);
	function scoreUp(address user) returns (bool res);
}

interface Share {
	function distributeTokens(address receiver);
	function distributeTokens(address receiver, uint tokensPerShare);
}