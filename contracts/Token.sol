pragma solidity ^0.4.17;

import "zeppelin-solidity/contracts/token/BurnableToken.sol";
import "zeppelin-solidity/contracts/token/MintableToken.sol";
import "zeppelin-solidity/contracts/token/PausableToken.sol";
import "zeppelin-solidity/contracts/token/DetailedERC20.sol";
import "./Interfaces.sol";
import "./Inbot.sol";

 /**
 * @title Contract that will work with ERC223 tokens.
 */
 
contract ERC223ReceivingContract { 
	/**
	 * @dev Standard ERC223 function that will handle incoming token transfers.
	 *
	 * @param _from  Token sender address.
	 * @param _value Amount of tokens.
	 * @param _data  Transaction metadata.
	 */
    function tokenFallback(address _from, uint _value, bytes _data) public;
}

contract InbotToken is InbotContract, MintableToken, BurnableToken, PausableToken, DetailedERC20 {
	event InbotTokenTransfer(address indexed from, address indexed to, uint value, bytes data);

	function InbotToken (string _name, string _symbol, uint8 _decimals) DetailedERC20(_name, _symbol, _decimals) public {
	}

	function callTokenFallback(address _from, address _to, uint256 _value, bytes _data) internal returns (bool) {
		uint codeLength;

        assembly {
            // Retrieve the size of the code on target address, this needs assembly .
            codeLength := extcodesize(_to)
        }

        if(codeLength > 0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(_from, _value, _data);
        }

        InbotTokenTransfer(_from, _to, _value, _data);

        return true;
	}

	/**
	* @dev Transfer the specified amount of ERC223 compliant tokens to the specified address.
	* @param _from 	The address to transfer from.
	* @param _to 	The address to transfer to.
	* @param _value The amount to be transferred.
	* @param _data  Transaction metadata.
	*/
	function transferFrom(address _from, address _to, uint256 _value, bytes _data) public whenNotPaused returns (bool) {
		assert(super.transferFrom(_from, _to, _value));
		return callTokenFallback(_from, _to, _value, _data);
	}

	/**
	* @dev Transfer the specified amount of ERC223 compliant tokens to the specified address.
	* @param _from 	The address to transfer from.
	* @param _to 	The address to transfer to.
	* @param _value The amount to be transferred.
	*/
	function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
		bytes memory empty;
		return transferFrom(_from, _to, _value, empty);
	}

	/**
	* @dev Transfer the specified amount of ERC223 compliant tokens to the specified address.
	* @param _to 	The address to transfer to.
	* @param _value The amount to be transferred.
	* @param _data  Transaction metadata.
	*/
	function transfer(address _to, uint256 _value, bytes _data) public whenNotPaused returns (bool) {
		assert(super.transfer(_to, _value));
		return callTokenFallback(msg.sender, _to, _value, _data);
	}

	/**
     * @dev Transfer the specified amount of ERC223 compliant tokens to the specified address.
     *      
     * @param _to    Receiver address.
     * @param _value Amount of tokens that will be transferred.
     */
    function transfer(address _to, uint _value) public whenNotPaused returns (bool) {
        bytes memory empty;
		return transfer(_to, _value, empty);
    }
} 