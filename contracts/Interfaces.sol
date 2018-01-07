pragma solidity ^0.4.17;

interface Gateway {
	function open(uint _introId, uint _bid, uint _creationTime, string _hashedInfo) public;
	function accept(uint _introId, address _ambassador, uint _updateTime) public;
	function endorse(uint _introId, uint _updateTime) public;
	function dispute(uint _introId, uint _updateTime) public;
	function withdraw(uint _introId, uint _updateTime) public;
	function resolve(uint _introId, uint _updateTime, string _resolution, bool _isSpam) public;
}

interface Score {
	function setScore(address user, uint score) public;
	function getScore(address user) public view returns (uint score);
	function scoreDown(address user) public returns (bool res);
	function scoreUp(address user) public returns (bool res);
}

interface Share {
	function rolloutDividends(address receiver) public;
	function distributeDividends(address receiver, uint tokensPerShare) public;
}