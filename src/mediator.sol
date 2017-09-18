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

    event IntroductionInitiated(address vendor, address ambassador);
    event IntroductionConfirmed(address vendor, address ambassador);
    event IntroductionEndorsed(address vendor, address ambassador);
    event IntroductionDisendorsed(address vendor, address ambassador);

    function setProxy(address proxy) auth {
        _proxy = TrustProxy(proxy);
    }

    function initiate(address vendor) stoppable returns (bool) {
        require(State.Stale == _transitions[vendor][msg.sender]);
        
        _transitions[vendor][msg.sender] = State.Initiated;
        
        IntroductionInitiated(vendor, msg.sender);

        return true;
    }

    function confirm(address ambassador) stoppable proxyExists returns (bool res) {
        require(State.Initiated == _transitions[msg.sender][ambassador]);
        require(_proxy.getToken().balanceOf(msg.sender) >= _proxy.getPricing().priceIntro(ambassador));

        uint256 deposit = _proxy.getPricing().priceIntro(ambassador);
        _transitions[msg.sender][ambassador] = State.Confirmed;
        _deposits[msg.sender][ambassador] = deposit;
        res = _proxy.getToken().approve(msg.sender, deposit);
        res = _proxy.getToken().transfer(this, deposit);

        IntroductionConfirmed(msg.sender, ambassador);
    }

    function endorse(address ambassador) stoppable proxyExists returns (bool res) {
        require(State.Confirmed == _transitions[msg.sender][ambassador]);
        require(_deposits[msg.sender][ambassador] > 0);

        uint256 deposit = _deposits[msg.sender][ambassador];
        _deposits[msg.sender][ambassador] = 0;
        _transitions[msg.sender][ambassador] = State.Endorsed;
        res = _proxy.getToken().transferFrom(this, ambassador, deposit);
        res = _proxy.getShareAllocation().allocate(msg.sender, ambassador, 1);

        IntroductionEndorsed(msg.sender, ambassador);
    }

    function disendorse(address ambassador) stoppable proxyExists returns (bool res) {
        require(State.Confirmed == _transitions[msg.sender][ambassador]);
        require(_deposits[msg.sender][ambassador] > 0);

        uint256 deposit = _deposits[msg.sender][ambassador];
        _deposits[msg.sender][ambassador] = 0;
        _transitions[msg.sender][ambassador] = State.Disendorsed;
        res = _proxy.getToken().transferFrom(this, msg.sender, deposit);

        IntroductionDisendorsed(msg.sender, ambassador);
    }

}