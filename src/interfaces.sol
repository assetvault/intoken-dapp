pragma solidity ^0.4.16;

interface Mediator {
	function initiate(address vendor) returns (bool res);
	function confirm(address ambassador) returns (bool res);
	function endorse(address ambassador) returns (bool res);
	function disendorse(address ambassador) returns (bool res);
}

interface ShareAllocation {
	function allocate(address vendor, address ambassador, uint shares) returns (bool res);
	function allocate(uint totalShares, uint shareType) returns (bool res);
}

interface Pricing {
	function priceShare(uint shareType, uint amount) returns (uint tokens);
	function priceIntro(address ambassador) returns (uint tokens);
}

interface Scoring {
	function setScore(address user, uint score);
	function getScore(address user) returns (uint score);
	function scoreDown(address user) returns (bool res);
	function scoreUp(address user) returns (bool res);
}

interface UserInfo {
	function setInfo(address user, string info, uint value);
	function getInfo(address user, string info) returns (uint value);
	function setInfoString(address user, string info, string value);
	function getInfoString(address user, string info) returns (string value);
}