pragma solidity ^0.4.17;

import "./Token.sol";
/** 
 * @title InToken (Inbot Token) contract. 
*/
contract InToken is InbotToken("InToken", "IN", 18) {
	uint public constant MAX_SUPPLY = 13*RAY;

	function InToken() public {
	}

	/**
	* @dev Function to mint tokens upper limited by MAX_SUPPLY.
	* @param _to The address that will receive the minted tokens.
	* @param _amount The amount of tokens to mint.
	* @return A boolean that indicates if the operation was successful.
	*/
	function mint(address _to, uint256 _amount) onlyAdmin canMint public returns (bool) {
		require(totalSupply.add(_amount) <= MAX_SUPPLY);

		return super.mint(_to, _amount);
	}
	
}