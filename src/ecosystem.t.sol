pragma solidity ^0.4.16;

import "ds-test/test.sol";
import "./interfaces.sol";
import "./mediator.sol";
import "./manager.sol";
import "./pricing.sol";
import "./scoring.sol";
import "./token.sol";
import "./guard.sol";
import "./proxy.sol";
import "./info.sol";

contract TokenUser {
    DSToken  token;

    function TokenUser(DSToken token_) {
        token = token_;
    }

    function doTransferFrom(address from, address to, uint amount)
        returns (bool)
    {
        return token.transferFrom(from, to, amount);
    }

    function doTransfer(address to, uint amount)
        returns (bool)
    {
        return token.transfer(to, amount);
    }

    function doApprove(address recipient, uint amount)
        returns (bool)
    {
        return token.approve(recipient, amount);
    }

    function doAllowance(address owner, address spender)
        constant returns (uint)
    {
        return token.allowance(owner, spender);
    }

    function doBalanceOf(address who) constant returns (uint) {
        return token.balanceOf(who);
    }

    function doSetName(bytes32 name) constant {
        token.setName(name);
    }

}

contract EcosystemTest is DSTest {
    address user1;
    address user2;
    TrustProxy proxy;
	TrustGuard guard;
	TrustToken token;
	InbotUserInfo info;
	TrustScoring scoring;
	TrustPricing pricing;
	TrustMediator mediator;
	TrustShareManager manager;

	function setUp() {
		guard = new TrustGuard();
		token = new TrustToken();
		user1 = new TokenUser(token);
        user2 = new TokenUser(token);

		info = new InbotUserInfo();
		pricing = new TrustPricing(10);
		scoring = new TrustScoring();
		mediator = new TrustMediator();
		manager = new TrustShareManager();

		proxy = new TrustProxy(token, pricing, scoring, info, mediator, manager);
		pricing.setProxy(proxy);
		manager.setProxy(proxy);
		mediator.setProxy(proxy);

		guard.permit(mediator, scoring, guard.ANY());
		guard.permit(mediator, manager, guard.ANY());
		guard.permit(manager, token, guard.ANY());
		scoring.setAuthority(guard);
		manager.setAuthority(guard);
		token.setAuthority(guard);
	}

	function testSetupPrecondition() {
        assertEq(token.balanceOf(this), 0);
        assertEq(token.balanceOf(user1), 0);
        assertEq(token.balanceOf(user2), 0);
    }

    function testFailTransfer() logs_gas {
        token.transfer(user1, 10);
    }
}