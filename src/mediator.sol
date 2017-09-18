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

    TrustProxy                                      _proxy;
    mapping (address => mapping (address => uint))  _deposits;
    mapping (address => mapping (address => State)) _transitions;

    modifier proxyExists() {
        require(_proxy != address(0x0));
        _;
    }

    event Initiated(address indexed vendor, address indexed ambassador, bool success);
    event Confirmed(address indexed vendor, address indexed ambassador, bool success);
    event Endorsed(address indexed vendor, address indexed ambassador, bool success);
    event Disendorsed(address indexed vendor, address indexed ambassador, bool success);

    function setProxy(address proxy) auth note {
        _proxy = TrustProxy(proxy);
    }

    function initiate(address vendor) stoppable note returns (bool) {
        require(State.Stale == _transitions[vendor][msg.sender]);
        
        _transitions[vendor][msg.sender] = State.Initiated;
        
        Initiated(vendor, msg.sender, true);

        return true;
    }

    function confirm(address ambassador) stoppable note proxyExists returns (bool res) {
        require(State.Initiated == _transitions[msg.sender][ambassador]);

        uint deposit = _proxy.getPricing().priceIntro(ambassador);
        require(_proxy.getToken().balanceOf(msg.sender) >= deposit);

        _transitions[msg.sender][ambassador] = State.Confirmed;
        _deposits[msg.sender][ambassador] = deposit;

        res = _proxy.getToken().approve(msg.sender, deposit);
        res = res && _proxy.getToken().transfer(this, deposit);

        Confirmed(msg.sender, ambassador, res);
    }

    function endorse(address ambassador) stoppable note proxyExists returns (bool res) {
        require(State.Confirmed == _transitions[msg.sender][ambassador]);
        
        uint deposit = _deposits[msg.sender][ambassador];
        require(deposit > 0);

        _deposits[msg.sender][ambassador] = 0;
        _transitions[msg.sender][ambassador] = State.Stale;

        res = _proxy.getScoring().scoreUp(ambassador);
        res = res && _proxy.getShareAllocation().allocate(msg.sender, ambassador, 1);
        res = res && _proxy.getToken().transferFrom(this, ambassador, deposit);

        Endorsed(msg.sender, ambassador, res);
    }

    function disendorse(address ambassador) stoppable note proxyExists returns (bool res) {
        require(State.Confirmed == _transitions[msg.sender][ambassador]);

        uint deposit = _deposits[msg.sender][ambassador];
        require(deposit > 0);
        
        _deposits[msg.sender][ambassador] = 0;
        _transitions[msg.sender][ambassador] = State.Stale;
        
        res = _proxy.getScoring().scoreDown(ambassador);
        res = res && _proxy.getToken().transferFrom(this, msg.sender, deposit);

        Disendorsed(msg.sender, ambassador, res);
    }

}