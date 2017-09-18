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
	function priceShare(uint shareType) returns (uint256 tokens);
	function priceIntro(address ambassador) returns (uint256 tokens);
}