pragma solidity ^0.4.16;

import "ds-stop/stop.sol";
import "./interfaces.sol";

contract InbotUserInfo is UserInfo, DSStop {
	mapping (address => mapping (string => uint)) 	_int_info;
	mapping (address => mapping (string => string)) _str_info;

	function getInfo(address user, string info) stoppable constant returns (uint value) {
		return _int_info[user][info];
	}

	function setInfo(address user, string info, uint value) auth stoppable note {
		_int_info[user][info] = value;	
	}

	function getInfoString(address user, string info) stoppable constant returns (string value) {
		return _str_info[user][info];
	}

	function setInfoString(address user, string info, string value) auth stoppable note {
		_str_info[user][info] = value;
	}
}