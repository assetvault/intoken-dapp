pragma solidity ^0.4.17;

import "./Interfaces.sol";
import "./Proxy.sol";
import "./Inbot.sol";
import "./Token.sol";

contract InbotMediatorGatewayEvents {
    event Opened(uint indexed id, address indexed actor, uint indexed time);
    event Accepted(uint indexed id, address indexed actor, uint indexed time);
    event Disputed(uint indexed id, address indexed actor, uint indexed time);
    event Endorsed(uint indexed id, address indexed actor, uint indexed time);
    event Withdrawn(uint indexed id, address indexed actor, uint indexed time);
    event Resolved(uint indexed id, address indexed actor, uint indexed time);
} 

contract InbotMediatorGateway is Gateway, InbotMediatorGatewayEvents, InbotContract, ERC223ReceivingContract {

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
     *  Asserts current state being _state1 OR _state2.
     *  @param _state1 Expected first state
     *  @param _state2 Expected second state
     *  @param _introId Intro Id
     */
    modifier atStates(uint _introId, State _state1, State _state2) {
        require(_state1 == intros[_introId].state
             || _state2 == intros[_introId].state);
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
        ambassadorPercentage = WAD.div(100).mul(70);
        platformFeeVault = _platformFeeVault;
    }
    
    /**
    * @dev Sets a percentage of any bid which an ambassador with 200IN% can get.
    * @param _percentage  The percentage which get an ambassador with 200IN%.
    */
    function setAmbassadorPercentage(uint _percentage) public onlyAdmin {
        require(_percentage > 0 && _percentage < 100);
        ambassadorPercentage = WAD.div(100).mul(_percentage); 
    }

    /**
    * @dev ERC223 compliant fallback to receive tokens to this contract's address.
    */
    function tokenFallback(address _from, uint _value, bytes _data) public {
        TokenReceived(_from, _value, _data);
    }

    /**
    * @dev Gets a state of an intro by _introId.
    * @param _introId  Intro's ID.
    * @return Intro's state.
    */
    function getIntroState(uint _introId) public view returns (State) {
        return intros[_introId].state;
    }

    /**
    * @dev Gets a bid of an intro by _introId.
    * @param _introId  Intro's ID.
    * @return Intro's bid value.
    */
    function getIntroBid(uint _introId) public view returns (uint) {
        return intros[_introId].bid;
    }

    /**
    * @dev Open an intro and deposit a bid to this contract's address.
    * @param _introId       Intro's ID.
    * @param _bid           Intro's bid value.
    * @param _creationTime  Intro's external creation time or '0' for now.
    * @param _hashedInfo    Intro's external info which is hashed for obfuscation.
    */
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

    /**
    * @dev Accept an intro and save the ambassador's address.
    * @param _introId     Intro's ID.
    * @param _ambassador  Intro's accepted ambassador address.
    * @param _updateTime  Intro's external update time or '0' for now.
    */
    function accept(
        uint _introId, 
        address _ambassador,
        uint _updateTime
    )
        public
        whenNotPaused 
        isVendor(_introId)
        atState(_introId, State.Open)
        transition(_introId, State.Accepted)
    {   
        intros[_introId].ambassador = _ambassador;

        Accepted(_introId, msg.sender, getTime(_updateTime));
    }

    /**
    * @dev Endorse an intro and charge platform and ambassador fees,
    *      allocate InShare to the ambassador and increase his/her IN%.
    * @param _introId     Intro's ID.
    * @param _updateTime  Intro's external update time or '0' for now.
    */
    function endorse(
        uint _introId, 
        uint _updateTime
    )
        public
        proxyExists
        whenNotPaused 
        isVendor(_introId)
        atStates(_introId, State.Accepted, State.Disputed)
        transition(_introId, State.Endorsed)
    {
        Intro storage intro = intros[_introId];

        uint ambassadorScore = proxy.getScore().getScore(intro.ambassador);
        uint ambassadorPercent = wmul(ambassadorScore.div(2), ambassadorPercentage);
        uint ambassadorFee = wmul(intro.bid, ambassadorPercent);
        uint platformFee = intro.bid - ambassadorFee;

        proxy.getToken().transfer(intro.ambassador, ambassadorFee);
        proxy.getToken().transfer(platformFeeVault, platformFee);
        proxy.getShare().mint(intro.ambassador, WAD);

        if (!introEndorsed[intro.vendor][intro.ambassador]) {
            introEndorsed[intro.vendor][intro.ambassador] = true;
            proxy.getScore().scoreUp(intro.ambassador);
        }

        Endorsed(_introId, msg.sender, getTime(_updateTime));
    }

    /**
    * @dev Dispute an intro (performed off-blockchain) as being spammy.
    * @param _introId     Intro's ID.
    * @param _updateTime  Intro's external update time or '0' for now.
    */
    function dispute(
        uint _introId, 
        uint _updateTime
    )
        public
        isVendor(_introId)
        atState(_introId, State.Accepted)
        transition(_introId, State.Disputed)
    {
        Disputed(_introId, msg.sender, getTime(_updateTime));
    }

    /**
    * @dev Withdraw from an intro and possibly return a bid.
    * @param _introId     Intro's ID.
    * @param _updateTime  Intro's external update time or '0' for now.
    */
    function withdraw(
        uint _introId, 
        uint _updateTime
    )
        public
        proxyExists
        whenNotPaused
        atStates(_introId, State.Open, State.Accepted)
        isIntroParty(_introId)
    {
        Intro storage intro = intros[_introId];

        if (intro.vendor == msg.sender) {
            intro.state = State.Withdrawn;
            proxy.getToken().transfer(intro.vendor, intro.bid);
            Withdrawn(_introId, msg.sender, getTime(_updateTime));
        } else {
            intro.state = State.Open;
            Opened(_introId, msg.sender, getTime(_updateTime));
        }
    }

    /**
    * @dev Resolve an intro by investigating off-blockchain and then executing transaction.
    * @param _introId     Intro's ID.
    * @param _updateTime  Intro's external update time or '0' for now.
    * @param _resolution  Intro's resolution (might be hashed for obfuscation).
    * @param _isSpam      A boolean that indicates intro is a spam or not.
    */
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
            endorse(_introId, _updateTime);
        }
    } 

}