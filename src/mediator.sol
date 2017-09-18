pragma solidity ^0.4.15;

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

    TrustProxy                                              _proxy;
    mapping (address => (mapping => (address => unit356)))  _deposits;
    mapping (address => (mapping => (address => State)))    _transitions;

    modifier condition(bool condition) {
        require(condition);
        _;
    }

    modifier proxyExists() {
        require(_proxy != address(0x0));
        _;
    }

    modifier inState(State state, ambassador, vendor) {
        require(state == _transitions[vendor][ambassador]);
        _;
    }

    event IntroductionInitiated(address vendor, address ambassador);
    event IntroductionConfirmed(address vendor, address ambassador);
    event IntroductionEndorsed(address vendor, address ambassador);
    event IntroductionDisendorsed(address vendor, address ambassador);

    function setProxy(address proxy) auth {
        _proxy = TrustProxy(proxy)
    }

    function initiate(address vendor) 
        stoppable
        inState(State.Stale, msg.sender, vendor)
        returns (bool)
    {
        _transitions[vendor][msg.sender] = State.Initiated;
        IntroductionInitiated(msg.sender, vendor);

        return true;
    }

    function confirm(address ambassador) 
        stoppable
        inState(State.Initiated, ambassador, msg.sender)
        condition(_proxy.getToken().balanceOf(msg.sender) >= _proxy.getPricing().priceIntro(ambassador))
        returns (bool res)
    {
        deposit = _proxy.getPricing().priceIntro(ambassador);
        _transitions[msg.sender][ambassador] = State.Confirmed;
        _deposits[msg.sender][ambassador] = deposit;
        res = _proxy.getToken().approve(msg.sender, deposit);
        res = _proxy.getToken().push(this, deposit);
        IntroductionConfirmed(msg.sender, vendor);
    }

    function endorse(address ambassador) 
        stoppable
        inState(State.Confirmed, ambassador, msg.sender)
        condition(_deposits[msg.sender][ambassador] > 0)
        returns (bool res)
    {
        deposit = _deposits[msg.sender][ambassador];
        _deposits[msg.sender][ambassador] = 0;
        _transitions[msg.sender][ambassador] = State.Endorsed;
        res = _proxy.getToken().pull(this, ambassador, deposit);
        IntroductionEndorsed(msg.sender, vendor);
    }

    function endorse(address ambassador) 
        stoppable
        inState(State.Confirmed, ambassador, msg.sender)
        condition(_deposits[msg.sender][ambassador] > 0)
        returns (bool res)
    {
        deposit = _deposits[msg.sender][ambassador];
        _deposits[msg.sender][ambassador] = 0;
        _transitions[msg.sender][ambassador] = State.Disendorsed;
        res = _proxy.getToken().pull(this, msg.sender, deposit);
        IntroductionDisendorsed(msg.sender, vendor);
    }

}