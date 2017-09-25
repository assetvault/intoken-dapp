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

contract EcosystemUser {
    TrustProxy proxy;

    function EcosystemUser(TrustProxy _proxy) {
        proxy = _proxy;
    }

    function doTransferFrom(address from, address to, uint amount)
        returns (bool)
    {
        return proxy.getToken().transferFrom(from, to, amount);
    }

    function doTransfer(address to, uint amount)
        returns (bool)
    {
        return proxy.getToken().transfer(to, amount);
    }

    function doApprove(address recipient, uint amount)
        returns (bool)
    {
        return proxy.getToken().approve(recipient, amount);
    }

    function doScoreUp() returns (bool) {
        proxy.getScoring().scoreUp(this);
    }

    function doInitiateIntro(address user) returns (bool) {
        return proxy.getMediator().initiate(user);
    }

    function doConfirmIntro(address user) returns (bool) {
        return proxy.getMediator().confirm(user);
    }

    function doEndorseIntro(address user) returns (bool) {
        return proxy.getMediator().endorse(user);
    }

    function doDisendorseIntro(address user) returns (bool) {
        return proxy.getMediator().disendorse(user);
    }

    function doAllocateShare(address user) returns (bool) {
        return proxy.getShareManager().allocate(user, this, 1);
    }
}

contract EcosystemTest is DSTest, TrustMediatorEvents, TrustShareManagerEvents {
    EcosystemUser user1;
    EcosystemUser user2;
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
        guard.permit(pricing, scoring, guard.ANY());
        guard.permit(manager, token, guard.ANY());
        scoring.setAuthority(guard);
        manager.setAuthority(guard);
        token.setAuthority(guard);
        
        user1 = new EcosystemUser(proxy);
        user2 = new EcosystemUser(proxy);
	}

	function testSetupPrecondition() {
        assertEq(token.balanceOf(this), 0);
        assertEq(token.balanceOf(user1), 0);
        assertEq(token.balanceOf(user2), 0);
    }

    function testFailTransfer() logs_gas {
        token.transfer(user1, 10);
    }

    function testFailScoreUp() logs_gas {
        user1.doScoreUp();
    }

    function testFailInitiateIntro() logs_gas {
        mediator.stop();
        user1.doInitiateIntro(user2);
    }

    function testInitateIntro() logs_gas {
        expectEventsExact(mediator);

        Initiated(user2, user1, true);

        user1.doInitiateIntro(user2);
    }

    function testFailConfirmIntroNotInState() logs_gas {
        user2.doConfirmIntro(user1);
    }

    function testFailConfirmIntroNoDeposit() logs_gas {
        expectEventsExact(mediator);

        Initiated(user2, user1, true);

        user1.doInitiateIntro(user2);
        user2.doConfirmIntro(user1);
    }

    function testConfirmIntro() logs_gas {
        token.mint(100);
        token.transfer(user2, 2);
        user2.doApprove(mediator, 2);

        expectEventsExact(mediator);

        Initiated(user2, user1, true);
        Confirmed(user2, user1, true);

        user1.doInitiateIntro(user2);
        user2.doConfirmIntro(user1);

        assertEq(token.balanceOf(user1), 0);
        assertEq(token.balanceOf(user2), 0);
        assertEq(token.balanceOf(mediator), 2);
        assertEq(token.allowance(user2, mediator), 0);
    }

    function testFailEndorseIntro() logs_gas {
        user2.doEndorseIntro(user2);
    }

    function testEndorseIntro() logs_gas {
        token.mint(100);
        token.transfer(user2, 2);
        user2.doApprove(mediator, 2);

        expectEventsExact(mediator);

        Initiated(user2, user1, true);
        Confirmed(user2, user1, true);
        Endorsed(user2, user1, true);

        user1.doInitiateIntro(user2);
        user2.doConfirmIntro(user1);
        user2.doEndorseIntro(user1);

        assertEq(token.balanceOf(user1), 0);
        assertEq(token.balanceOf(user2), 0);
        assertEq(token.balanceOf(mediator), 2);
        assertEq(token.allowance(user2, mediator), 0);
    }

    function testFailDisndorseIntro() logs_gas {
        user2.doDisendorseIntro(user2);
    }

    function testDisendorseIntro() logs_gas {
        token.mint(100);
        token.transfer(user2, 2);
        user2.doApprove(mediator, 2);

        expectEventsExact(mediator);

        Initiated(user2, user1, true);
        Confirmed(user2, user1, true);
        Disendorsed(user2, user1, true);

        user1.doInitiateIntro(user2);
        user2.doConfirmIntro(user1);
        user2.doDisendorseIntro(user1);

        assertEq(token.balanceOf(user1), 0);
        assertEq(token.balanceOf(user2), 0);
        assertEq(token.balanceOf(mediator), 2);
        assertEq(token.allowance(user2, mediator), 0);
    }

    function testFailResolveIntro() logs_gas {
        mediator.resolve(user1, user2);
    }

    function testResolveEndorsedIntro() logs_gas {
        token.mint(100);
        token.transfer(user2, 8);
        user2.doApprove(mediator, 8);
        scoring.setScore(user1, 200);

        expectEventsExact(mediator);

        Initiated(user2, user1, true);
        Confirmed(user2, user1, true);
        Endorsed(user2, user1, true);
        Resolved(user2, user1, true);

        user1.doInitiateIntro(user2);
        user2.doConfirmIntro(user1);
        user2.doEndorseIntro(user1);
        mediator.resolve(user2, user1);

        assertEq(token.balanceOf(user1), 0);
        assertEq(token.balanceOf(user2), 0);
        assertEq(token.balanceOf(mediator), 8);
        assertEq(token.allowance(mediator, user1), 8);
        assertEq(token.allowance(user2, mediator), 0);
        assertEq(manager.getShare(user2, user1), 1);
        assertEq(scoring.getScore(user1), 200);
    }

    function testResolveDisendorsedIntro() logs_gas {
        token.mint(100);
        token.transfer(user2, 6);
        user2.doApprove(mediator, 6);
        info.setInfo(user1, "corp_size", 2);
        info.setInfo(user1, "corp_position", 2);

        expectEventsExact(mediator);

        Initiated(user2, user1, true);
        Confirmed(user2, user1, true);
        Disendorsed(user2, user1, true);
        Resolved(user2, user1, true);

        user1.doInitiateIntro(user2);
        user2.doConfirmIntro(user1);
        user2.doDisendorseIntro(user1);
        mediator.resolve(user2, user1);

        assertEq(token.balanceOf(user1), 0);
        assertEq(token.balanceOf(user2), 0);
        assertEq(token.balanceOf(mediator), 6);
        assertEq(token.allowance(mediator, user2), 6);
        assertEq(token.allowance(user2, mediator), 0);
        assertEq(manager.getShare(user2, user1), 0);
        assertEq(scoring.getScore(user1), 40);
    }

    function testFailAllocateShare() logs_gas {
        user1.doAllocateShare(user2);
    }

    function testAllocateOneShare() logs_gas {
        expectEventsExact(manager);

        SharesAllocated(user1, user2, 1, true);

        manager.allocate(user1, user2, 1);

        assertEq(manager.getShare(user1, user2), 1);
    }

    function testEscrowIncome() logs_gas {
        expectEventsExact(manager);

        IncomeEscrowed(user1, 95, true);

        manager.escrow(user1, 0, 1000);

        assertEq(manager.getEscrow(user1), 23);
        assertEq(token.balanceOf(this), 23);
        assertEq(token.balanceOf(user1), 0);
        assertEq(token.balanceOf(manager), 72);
        assertEq(token.allowance(manager, user1), 49);
    }

    function testDistributeShares() logs_gas {
        expectEventsExact(manager);

        IncomeEscrowed(user1, 95, true);
        SharesDistributed(user1, 1, 118, true);

        manager.allocate(user1, user2, 1);
        manager.escrow(user1, 0, 1000);
        manager.distribute(user1, 0, 1000);

        assertEq(manager.getEscrow(user1), 0);
        assertEq(manager.getShare(user1, user2), 1);
        assertEq(token.balanceOf(this), 23);
        assertEq(token.balanceOf(user1), 0);
        assertEq(token.balanceOf(manager), 167);
        assertEq(token.allowance(manager, user1), 49);
        assertEq(token.allowance(manager, user2), 118);
    }
}