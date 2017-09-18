pragma solidity ^0.4.16;

import "ds-stop/stop.sol";
import "./interfaces.sol";
import "./proxy.sol";

contract TrustMediator is Mediator, DSStop {
    enum State {
        Stale,
        Initiated,
        Confirmed
    }

    TrustProxy                                         _proxy;
    mapping (address => mapping (address => uint256))  _deposits;
    mapping (address => mapping (address => State))    _transitions;

    modifier condition(bool _condition) {
        require(_condition);
        _;
    }

    modifier proxyExists() {
        require(_proxy != address(0x0));
        _;
    }

    event Initiated(address indexed vendor, address indexed ambassador);
    event Confirmed(address indexed vendor, address indexed ambassador);
    event Endorsed(address indexed vendor, address indexed ambassador);
    event Disendorsed(address indexed vendor, address indexed ambassador);

    function setProxy(address proxy) auth {
        _proxy = TrustProxy(proxy);
    }

    function initiate(address vendor) stoppable returns (bool) {
        require(State.Stale == _transitions[vendor][msg.sender]);
        
        _transitions[vendor][msg.sender] = State.Initiated;
        
        Initiated(vendor, msg.sender);

        return true;
    }

    function confirm(address ambassador) stoppable proxyExists returns (bool res) {
        require(State.Initiated == _transitions[msg.sender][ambassador]);

        uint256 deposit = _proxy.getPricing().priceIntro(ambassador);
        require(_proxy.getToken().balanceOf(msg.sender) >= deposit);

        _transitions[msg.sender][ambassador] = State.Confirmed;
        _deposits[msg.sender][ambassador] = deposit;
        res = _proxy.getToken().approve(msg.sender, deposit);
        res = _proxy.getToken().transfer(this, deposit);

        Confirmed(msg.sender, ambassador);
    }

    function endorse(address ambassador) stoppable proxyExists returns (bool res) {
        require(State.Confirmed == _transitions[msg.sender][ambassador]);
        
        uint256 deposit = _deposits[msg.sender][ambassador];
        require(deposit > 0);

        _deposits[msg.sender][ambassador] = 0;
        _transitions[msg.sender][ambassador] = State.Stale;
        res = _proxy.getToken().transferFrom(this, ambassador, deposit);
        res = _proxy.getShareAllocation().allocate(msg.sender, ambassador, 1);

        Endorsed(msg.sender, ambassador);
    }

    function disendorse(address ambassador) stoppable proxyExists returns (bool res) {
        require(State.Confirmed == _transitions[msg.sender][ambassador]);

        uint256 deposit = _deposits[msg.sender][ambassador];
        require(deposit > 0);
        
        _deposits[msg.sender][ambassador] = 0;
        _transitions[msg.sender][ambassador] = State.Stale;
        res = _proxy.getToken().transferFrom(this, msg.sender, deposit);

        Disendorsed(msg.sender, ambassador);
    }

}