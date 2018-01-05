pragma solidity ^0.4.17;

import "zeppelin-solidity/contracts/ownership/CanReclaimToken.sol";
import "./Interfaces.sol";
import "./Proxy.sol";
import "./Inbot.sol";

contract InbotMediatorGatewayEvents {
    event Opened(uint indexed id, address indexed actor, uint indexed time);
    event Accepted(uint indexed id, address indexed actor, uint indexed time);
    event Disputed(uint indexed id, address indexed actor, uint indexed time);
    event Endorsed(uint indexed id, address indexed actor, uint indexed time);
    event Withdrawn(uint indexed id, address indexed actor, uint indexed time);
    event Resolved(uint indexed id, address indexed actor, uint indexed time);
} 

contract InbotMediatorGateway is Mediator, CanReclaimToken, InbotMediatorGatewayEvents, InbotContract {

    enum State {Null, Open, Accepted, Endorsed, Disputed, Withdrawn}

    struct Intro {
        State state;
        uint bid;
        address vendor;
        address ambassador;
        uint creationTime;
        string hashedInfo;
        string resolution;
    }

    uint                                           public ambassadorPercentage;
    address                                        public platformFeeVault;
    mapping (uint => Intro)                        public intros;
    mapping (address => mapping (address => bool)) public introEndorsed;

    /**
     *  Asserts current state.
     *  @param _state Expected state
     *  @param _introId Intro Id
     */
    modifier atState(uint _introId, State _state) {
        require(_state == intros[_introId].state);
        _;
    }

    /**
     *  Asserts vendor's identity.
     *  @param _introId Intro Id
     */
    modifier isVendor(uint _introId) {
        require(intros[_introId].vendor == msg.sender
            || hasRole(msg.sender, ROLE_ADMIN));
        _;
    }

    /**
     *  Asserts ambassador's or vendor's identity.
     *  @param _introId Intro Id
     */
    modifier isIntroParty(uint _introId) {
        require(intros[_introId].ambassador == msg.sender
             || intros[_introId].vendor == msg.sender
             || hasRole(msg.sender, ROLE_ADMIN));
        _;
    }

    /**
     *  Performs a transition after function execution.
     *  @param _state Next state
     *  @param _introId Intro Id
     */
    modifier transition(uint _introId, State _state) {
        _;
        intros[_introId].state = _state;
    }

    function InbotMediatorGateway(address _platformFeeVault) public {
        ambassadorPercentage = WAD/100 * 70;
        platformFeeVault = _platformFeeVault;
    }
    
    function setAmbassadorPercentage(uint _percentage) public onlyAdmin {
        require(_percentage > 0 && _percentage < 100);
        ambassadorPercentage = WAD/100 * _percentage; 
    }

    function reclaimToken() public onlyAdmin proxyExists {
        this.reclaimToken(proxy.getToken());
    }

    function open(
        uint _introId, 
        uint _bid, 
        uint _creationTime,
        string _hashedInfo
    )
        public
        proxyExists
        whenNotPaused
        atState(_introId, State.Null)
        transition(_introId, State.Open)
    {
        require(_introId > 0);
        require(_bid > 0);

        proxy.getToken().transferFrom(msg.sender, this, _bid);
        uint validTime  = getTime(_creationTime);
        
        intros[_introId] = Intro({
            state: State.Open,
            bid: _bid,
            vendor: msg.sender,
            ambassador: address(0x0),
            creationTime: validTime,
            hashedInfo: _hashedInfo,
            resolution: ""
        });
        
        Opened(_introId, msg.sender, validTime);
    }

    function accept(
        uint _introId, 
        address _ambassador,
        uint _updateTime
    )
        public
        proxyExists
        whenNotPaused 
        isVendor(_introId)
        atState(_introId, State.Open)
        transition(_introId, State.Accepted)
    {   
        intros[_introId].ambassador = _ambassador;

        Accepted(_introId, msg.sender, getTime(_updateTime));
    }

    function endorse(
        uint _introId, 
        uint _updateTime
    )
        public
        proxyExists
        whenNotPaused 
        isVendor(_introId)
        atState(_introId, State.Accepted)
        transition(_introId, State.Endorsed)
    {
        Intro storage intro = intros[_introId];

        uint ambassadorScore = proxy.getScore().getScore(intro.ambassador);
        uint ambassadorPercent = wmul(ambassadorScore/2, ambassadorPercentage);
        uint ambassadorFee = wmul(intro.bid, ambassadorPercent);
        uint platformFee = wmul(intro.bid, WAD - ambassadorPercent);

        proxy.getToken().transfer(intro.ambassador, ambassadorFee);
        proxy.getToken().transfer(platformFeeVault, platformFee);
        proxy.getShare().mint(intro.ambassador, WAD);

        if (!introEndorsed[intro.vendor][intro.ambassador]) {
            introEndorsed[intro.vendor][intro.ambassador] = true;
            proxy.getScore().scoreUp(intro.ambassador);
        }

        Endorsed(_introId, msg.sender, getTime(_updateTime));
    }

    function dispute(
        uint _introId, 
        uint _updateTime
    )
        public
        proxyExists
        isVendor(_introId)
        atState(_introId, State.Accepted)
        transition(_introId, State.Disputed)
    {
        Disputed(_introId, msg.sender, getTime(_updateTime));
    }

    function withdraw(
        uint _introId, 
        uint _updateTime
    )
        public
        proxyExists
        whenNotPaused 
        isIntroParty(_introId)
    {
        Intro storage intro = intros[_introId];
        require(State.Open == intro.state || State.Accepted == intro.state);

        if (intro.vendor == msg.sender) {
            intro.state = State.Withdrawn;
            proxy.getToken().transfer(intro.vendor, intro.bid);
            Withdrawn(_introId, msg.sender, getTime(_updateTime));
        } else {
            intro.state = State.Open;
            Opened(_introId, msg.sender, getTime(_updateTime));
        }
    }

    function resolve(
        uint _introId, 
        uint _updateTime,
        string _resolution,
        bool _isSpam
    )
        public
        proxyExists
        whenNotPaused 
        onlyAdmin
    {
        Intro storage intro = intros[_introId];

        if (_isSpam) {
            intro.state = State.Open;
            intro.resolution = _resolution;
            proxy.getScore().scoreDown(intro.ambassador);
            Opened(_introId, msg.sender, getTime(_updateTime));
        } else {
            intro.resolution = _resolution;
            this.endorse(_introId, _updateTime);
        }
    } 

}