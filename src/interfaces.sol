pragma solidity ^0.4.15;

interface Mediator {
	function initiate(address vendor);
	function confirm(address ambassador);
	function endorse(address ambassador);
	function disendorse(address ambassador);
}

interface ShareAllocation {
	function allocate(address vendor, address ambassador, uint shares);
	function allocate(uint totalShares, uint type);
}

interface Pricing {
	function priceShare(uint type);
	function priceIntro(address ambassador);
}