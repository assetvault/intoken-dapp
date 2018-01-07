pragma solidity ^0.4.17;

import "./Token.sol";
import "./InToken.sol";

contract InShareEvents {
	event DividendsDistributed(address indexed receiver, uint shares, uint value);	
	event DividendsRolledOut(address indexed receiver, uint shares, uint value);	
}

/** 
 * @title InShare (Inbot Share) contract. 
*/
contract InShare is InbotToken("InShare", "INS", 18), InShareEvents {
	uint constant cap6B = 6*RAY;
	uint constant cap7B = 7*RAY;
	uint constant cap8B = 8*RAY;
	uint constant cap9B = 9*RAY;
	
	function InShare() public {
		paused = true;
	}
	
	/**
	 * @dev Rollout dividends in terms of INT tokens to the specified address.
	 *		Exact number of INT tokens will be based the current supply and the
	 *      Inbot Score of the receiving (destination) address.
	 *     
	 * @param receiver    Divident receiver address.
	 */
	function rolloutDividends(address receiver) 
		public
		onlyAdmin 
		proxyExists
	{
		require(balances[receiver] > 0);

		uint tokens;
		uint supply = proxy.getToken().totalSupply(); 
		uint score = proxy.getScore().getScore(receiver);
		require(score > 0);

		if (supply < cap6B) {
			tokens = balances[receiver].mul(10);
		} else if (supply < cap7B) {
			tokens = balances[receiver].mul(7);
		} else if (supply < cap8B) {
			tokens = balances[receiver].mul(5);
		} else if (supply < cap9B) {
			tokens = balances[receiver].mul(3);
		} else  {
			tokens = balances[receiver];
		}

		uint dividends = wmul(tokens, score);

		proxy.getToken().mint(receiver, dividends);			
		DividendsRolledOut(receiver, balances[receiver], dividends);
	}

	/**
	 * @dev Distribute dividends in terms of INT tokens to the specified address.
	 *		Exact number of INT tokens will be based the Inbot Score of the 
	 *		receiving (destination) address and provided number of tokens
	 *		per InShare (INS).
	 *     
	 * @param receiver    		Divident receiver address.
	 * @param dividendsPerShare INT tokens per InShare.
	 */
	function distributeDividends(address receiver, uint dividendsPerShare)
		public
		onlyRole(ROLE_VENDOR) 
		proxyExists
	{
		require(balances[receiver] > 0);
		require(dividendsPerShare > 0);

		uint score = proxy.getScore().getScore(receiver);
		require(score > 0);

		uint dividends = wmul(balances[receiver].mul(dividendsPerShare), score);
		proxy.getToken().transferFrom(msg.sender, receiver, dividends);			
		DividendsDistributed(receiver, balances[receiver], dividends);
	}
}