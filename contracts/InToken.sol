pragma solidity ^0.4.17;

import "zeppelin-solidity/contracts/token/CappedToken.sol";
import "./Token.sol";
/** 
 * @title InToken (Inbot Token) contract. 
*/
contract InToken is InbotToken("InToken", "INT", 18), CappedToken {
	uint public constant MAX_SUPPLY = 10*RAY;

	function InToken() CappedToken(MAX_SUPPLY) public {
	}
	
}