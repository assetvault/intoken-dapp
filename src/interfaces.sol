pragma solidity ^0.4.16;

interface Mediator {
	function initiate(address vendor) returns (bool res);
	function confirm(address ambassador) returns (bool res);
	function endorse(address ambassador) returns (bool res);
	function disendorse(address ambassador) returns (bool res);
	function resolve(address vendor, address ambassador) returns (bool res);
}

interface ShareManager {
	function getShare(address vendor, address ambassador) constant returns (uint share);
	function allocate(address vendor, address ambassador, uint shares) returns (bool res);
	function distribute(address vendor, uint8 shareType, uint amount) returns (bool res);
	function escrow(address vendor, uint8 shareType, uint amount) returns (bool res);
}

interface Pricing {
	function priceShare(uint8 shareType, uint amount) returns (uint tokens);
	function priceIntro(address ambassador) returns (uint tokens);
}

interface Scoring {
	function setScore(address user, uint score);
	function getScore(address user) constant returns (uint score);
	function scoreDown(address user) returns (bool res);
	function scoreUp(address user) returns (bool res);
}

interface UserInfo {
	function setInfo(address user, string info, uint value);
	function getInfo(address user, string info) constant returns (uint value);
	function setInfoString(address user, string info, string value);
	function getInfoString(address user, string info) constant returns (string value);
}