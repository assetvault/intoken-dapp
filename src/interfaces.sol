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
	function getScore(address ambassador) returns (uint score);
	function scoreDown(address ambassador) returns (bool res);
	function scoreUp(address ambassador) returns (bool res);
}

interface UserInfo {
	function getInfo(address user, string info) returns (uint value);
	function setInfo(address user, string info, uint value);
	function getInfoString(address user, string info) returns (string value);
	function setInfoString(address user, string info, string value);
}