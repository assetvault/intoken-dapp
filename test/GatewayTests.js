const BigNumber = require("bignumber.js");
const InToken = artifacts.require("InToken");
const InShare = artifacts.require("InShare");
const InScore = artifacts.require("InScore");
const Gateway = artifacts.require("InbotMediatorGateway");
const full100PercentScore = BigNumber("1e+18");
const oneToken = BigNumber("1e+18");

contract("Gateway", function(accounts) {
  let share;
  let token;

  const INTRO_ID1 = 1;
  const INTRO_ID2 = 2;
  const INTRO_ID3 = 3;
  const INTRO_ID4 = 4;
  const INTRO_ID5 = 5;

  before(async() => {
    token = await InToken.deployed();
    share = await InShare.deployed();
    score = await InScore.deployed();
    gateway = await Gateway.deployed();
    await token.mint(accounts[2], oneToken.mul(10).valueOf());
  });

  it("vendor should be able to open an intro request and deposit 1 INT bid", async() => {
    await token.approve(Gateway.address, oneToken.valueOf(), {from: accounts[2]});
    await gateway.open(INTRO_ID1, oneToken.valueOf(), 0, "", {from: accounts[2]});
    let balance = await token.balanceOf.call(accounts[2]);
    let introState = await gateway.getIntroState.call(INTRO_ID1);
    let introBid = await gateway.getIntroBid.call(INTRO_ID1);
    assert.equal(introState.valueOf(), 1, "State.Opened should be saved to intro details");
    assert.equal(introBid.valueOf(), oneToken.valueOf(), "1 INT bid should be saved to intro details");
    assert.equal(balance.valueOf(), oneToken.mul(9).valueOf(), "9 INT should remain in the account_2");
  });

  it("non-vendor should fail to accept an intro suggestion", async() => {
    try {
      let result = await gateway.accept(INTRO_ID1, accounts[3], 0, {from: accounts[1]});
      throw new Error('Promise was unexpectedly fulfilled. Result: ' + result);
    } catch (error) {
      assert.isAbove(error.message.search('revert'), -1, 'Error containing "revert" must be returned');
    }
  });

  it("vendor should be able to accept an intro suggestion", async() => {
    await gateway.accept(INTRO_ID1, accounts[3], 0, {from: accounts[2]});
    let introState = await gateway.getIntroState.call(INTRO_ID1);
    let intro = await gateway.intros.call(INTRO_ID1);
    assert.equal(introState.valueOf(), 2, "State.Accepted should be saved to intro details");
    assert.equal(intro[3], accounts[3], "Ambassador address (account_3) should be saved to intro details");
  });

  it("non-vendor should fail to dispute just opened intro", async() => {
    try {
      await gateway.open(INTRO_ID2, oneToken.valueOf(), 0, "", {from: accounts[2]});
      let result = await gateway.dispute(INTRO_ID2, 0, {from: accounts[2]});
      throw new Error('Promise was unexpectedly fulfilled. Result: ' + result);
    } catch (error) {
      assert.isAbove(error.message.search('revert'), -1, 'Error containing "revert" must be returned');
    }
  });

  it("vendor should be able to dispute an accepted intro", async() => {
    await gateway.dispute(INTRO_ID1, 0, {from: accounts[2]});
    let introState = await gateway.getIntroState.call(INTRO_ID1);
    assert.equal(introState.valueOf(), 4, "State.Disputed should be saved to intro details");
  });

  it("admin should be able to resolve any disputed intro being spam and rollback it to the open state", async() => {
    await gateway.resolve(INTRO_ID1, 0, "admin resolution", true);
    let introState = await gateway.getIntroState.call(INTRO_ID1);
    let intro = await gateway.intros.call(INTRO_ID1);
    let ambassadorScore = await score.getScore.call(accounts[3]);
    assert.equal(introState.valueOf(), 1, "State.Opened should be saved to intro details");
    assert.equal(intro[6], "admin resolution", "Resolution should be saved to intro details");
    assert.equal(ambassadorScore.valueOf(), full100PercentScore.mul(0.4).valueOf(), "Default ambassador's IN% should be decreased to 40%");
  });

  it("admin should be able to resolve any disputed intro NOT being spam and endorse it", async() => {
    await gateway.accept(INTRO_ID1, accounts[4], 0, {from: accounts[2]});
    await gateway.dispute(INTRO_ID1, 0, {from: accounts[2]});
    await gateway.resolve(INTRO_ID1, 0, "admin resolution", false);
    let introState = await gateway.getIntroState.call(INTRO_ID1);
    let intro = await gateway.intros.call(INTRO_ID1);
    let ambassadorScore = await score.getScore.call(accounts[4]);
    let ambassadorBalance = await token.balanceOf.call(accounts[4]);
    let ambassadorShares = await share.balanceOf.call(accounts[4]);
    let vaultBalance = await token.balanceOf.call(accounts[1]);
    assert.equal(introState.valueOf(), 3, "State.Endorsed should be saved to intro details");
    assert.equal(intro[6], "admin resolution", "Resolution should be saved to intro details");
    assert.equal(ambassadorScore.valueOf(), full100PercentScore.mul(0.6).valueOf(), "Default ambassador's IN% should be increased to 60%");
    assert.equal(ambassadorBalance.valueOf(), oneToken.mul(0.175).valueOf(), "Ambassador receives 17.5% of the bid value if his IN% is 50%");
    assert.equal(vaultBalance.valueOf(), oneToken.mul(0.825).valueOf(), "Inbot platform receives 82.5% of the bid value if ambassador's IN% is 50%");
    assert.equal(ambassadorShares.valueOf(), oneToken.valueOf(), "Ambassador should receive 1 INS as a result of endorsement");
  });

  it("vendor should be able to withdraw an open intro and refund a bid", async() => {
    await token.approve(Gateway.address, oneToken.valueOf(), {from: accounts[2]});
    await gateway.open(INTRO_ID2, oneToken.valueOf(), 0, "", {from: accounts[2]});
    await gateway.withdraw(INTRO_ID2, 0, {from: accounts[2]});
    let balance = await token.balanceOf.call(accounts[2]);
    let introState = await gateway.getIntroState.call(INTRO_ID2);
    assert.equal(introState.valueOf(), 5, "State.Disputed should be saved to intro details");
    assert.equal(balance.valueOf(), oneToken.mul(9).valueOf(), "9 INT should remain in the account_2");
  });

  it("vendor should be able to withdraw an accepted intro and refund a bid", async() => {
    await token.approve(Gateway.address, oneToken.valueOf(), {from: accounts[2]});
    await gateway.open(INTRO_ID3, oneToken.valueOf(), 0, "", {from: accounts[2]});
    await gateway.accept(INTRO_ID3, accounts[3], 0, {from: accounts[2]});
    await gateway.withdraw(INTRO_ID3, 0, {from: accounts[2]});
    let balance = await token.balanceOf.call(accounts[2]);
    let introState = await gateway.getIntroState.call(INTRO_ID3);
    assert.equal(introState.valueOf(), 5, "State.Disputed should be saved to intro details");
    assert.equal(balance.valueOf(), oneToken.mul(9).valueOf(), "9 INT should remain in the account_2");
  });

  it("ambassador should be able to withdraw an accepted intro and rollback it to the open state", async() => {
    await token.approve(Gateway.address, oneToken.valueOf(), {from: accounts[2]});
    await gateway.open(INTRO_ID4, oneToken.valueOf(), 0, "", {from: accounts[2]});
    await gateway.accept(INTRO_ID4, accounts[3], 0, {from: accounts[2]});
    await gateway.withdraw(INTRO_ID4, 0, {from: accounts[3]});
    let balance = await token.balanceOf.call(accounts[2]);
    let introState = await gateway.getIntroState.call(INTRO_ID4);
    assert.equal(introState.valueOf(), 1, "State.Opened should be saved to intro details");
    assert.equal(balance.valueOf(), oneToken.mul(8).valueOf(), "8 INT should remain in the account_2");
  });

});