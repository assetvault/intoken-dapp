pragma solidity ^0.4.17;

import "./Token.sol";

contract InShareEvents {
	event TokensDistributed(address indexed receiver, uint shares, uint tokens);	
}

/** 
 * @title InShare (Inbot Share) contract. 
*/
contract InShare is InbotToken("InShare", "INS", 5), InShareEvents {
	
	function InShare() public {
		paused = true;
	}

	/**
	* @dev Function to mint tokens from another "admin" address. 
	* @param _to The address that will receive the minted tokens.
	* @param _amount The amount of tokens to mint.
	* @return A boolean that indicates if the operation was successful.
	*/
	function mint(address _to, uint256 _amount) public onlyAdmin canMint returns (bool) {
		return super.mint(_to, _amount);
	}
	
	/**
	 * @dev Distribute dividents in terms of INT tokens to the specified address.
	 *		Exact number of INT tokens will be based the current supply and the
	 *      Inbot Score of the receiving (destination) address.
	 *     
	 * @param receiver    Divident receiver address.
	 */
	function distributeTokens(address receiver) 
		public
		onlyRole(ROLE_VENDOR) 
		proxyExists
	{
		require(balances[receiver] > 0);

		uint tokens;
		uint score = proxy.getScore().getScore(receiver);
		require(score > 0);

		if (totalSupply < 6*RAY) {
			tokens = balances[receiver] * 10;
		} else if (totalSupply < 7*RAY) {
			tokens = balances[receiver] * 7;
		} else if (totalSupply < 8*RAY) {
			tokens = balances[receiver] * 5;
		} else if (totalSupply < 9*RAY) {
			tokens = balances[receiver] * 3;
		} else  {
			tokens = balances[receiver];
		}

		proxy.getToken().transferFrom(msg.sender, receiver, wmul(tokens, score));			
		TokensDistributed(receiver, balances[receiver], tokens);
	}

	/**
	 * @dev Distribute dividents in terms of INT tokens to the specified address.
	 *		Exact number of INT tokens will be based the Inbot Score of the 
	 *		receiving (destination) address and provided number of tokens
	 *		per Trust Share (T-Share).
	 *     
	 * @param receiver    		Divident receiver address.
	 * @param tokensPerShare    INT tokens per InShare.
	 */
	function distributeTokens(address receiver, uint tokensPerShare)
		public
		onlyRole(ROLE_VENDOR) 
		proxyExists
	{
		require(balances[receiver] > 0);

		uint score = proxy.getScore().getScore(receiver);
		require(score > 0);

		uint tokens = balances[receiver] * tokensPerShare;
		proxy.getToken().transferFrom(msg.sender, receiver, wmul(tokens, score));			
		TokensDistributed(receiver, balances[receiver], tokens);
	}
}