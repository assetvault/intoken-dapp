pragma solidity ^0.4.16;

import "ds-stop/stop.sol";
import "./interfaces.sol";
import "./proxy.sol";

contract TrustMediator is Mediator, DSStop {
    enum State {
        Stale,
        Initiated,
        Confirmed,
        Endorsed,
        Disendorsed
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
    event Resolved(address indexed vendor, address indexed ambassador, bool success);
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

    function confirm(address ambassador) 
        stoppable 
        note 
        proxyExists 
        returns (bool res) 
    {
        require(State.Initiated == _transitions[msg.sender][ambassador]);

        uint deposit = _proxy.getPricing().priceIntro(ambassador);
        require(_proxy.getToken().balanceOf(msg.sender) >= deposit);

        _transitions[msg.sender][ambassador] = State.Confirmed;
        _deposits[msg.sender][ambassador] = deposit;

        res = _proxy.getToken().transfer(this, deposit);

        Confirmed(msg.sender, ambassador, res);
    }

    function endorse(address ambassador) stoppable note returns (bool res) {
        require(State.Confirmed == _transitions[msg.sender][ambassador]);
        
        _transitions[msg.sender][ambassador] = State.Endorsed;

        Endorsed(msg.sender, ambassador, true);

        return true;
    }

    function disendorse(address ambassador) stoppable note returns (bool res) {
        require(State.Confirmed == _transitions[msg.sender][ambassador]);

        _transitions[msg.sender][ambassador] = State.Disendorsed;

        Disendorsed(msg.sender, ambassador, true);

        return true;
    }

    function resolve(address vendor, address ambassador) 
        auth 
        stoppable 
        note 
        proxyExists 
        returns (bool res) 
    {
        require(State.Endorsed == _transitions[vendor][ambassador]
             || State.Disendorsed == _transitions[vendor][ambassador]);

        uint deposit = _deposits[vendor][ambassador];
        require(deposit > 0);
        
        _deposits[vendor][ambassador] = 0;
        _transitions[vendor][ambassador] = State.Stale;

        if (State.Endorsed == _transitions[vendor][ambassador]) {
            res = _proxy.getShareManager().allocate(vendor, ambassador, 1);
            res = res && _proxy.getScoring().scoreUp(ambassador);
            res = res && _proxy.getToken().approve(ambassador, deposit);
        }
        if (State.Disendorsed == _transitions[vendor][ambassador]) {
            res = _proxy.getScoring().scoreDown(ambassador);
            res = res && _proxy.getToken().approve(vendor, deposit);
        }

        Resolved(vendor, ambassador, res);
    } 

}