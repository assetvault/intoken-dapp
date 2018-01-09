const BigNumber = require("bignumber.js");
const InToken = artifacts.require("InToken");
const InShare = artifacts.require("InShare");
const oneToken = BigNumber("1e+18");

contract("InShare", function(accounts) {
  let share;
  let token;

  before(async() => {
    token = await InToken.deployed();
    share = await InShare.deployed();
  });

  it("should have 0 INS in the owning account when deployed", async() => {
    let balance = await share.balanceOf.call(accounts[0]);
    assert.equal(balance.valueOf(), 0, "0 was in the owning account");
  });

  it("should be able to mint 1 INS and put them in the owning account", async() => {
    let result = await share.mint(accounts[0], oneToken.valueOf());
    let event1 = result.logs[0].args;
    assert.equal(event1.to, accounts[0]);
    assert.equal(event1.amount, oneToken.valueOf());
    let event2 = result.logs[1].args;
    assert.equal(event2.from, 0x0);
    assert.equal(event2.to, accounts[0]);
    assert.equal(event2.value, oneToken.valueOf());
    let balance = await share.balanceOf.call(accounts[0]);
    assert.equal(balance.valueOf(), oneToken.valueOf(), "1 INS has landed in the owning account");
  });

  it("should fail to transfer any INS from the beginning", async() => {
    try {
      let result = await share.transfer(accounts[1], oneToken.valueOf());
      throw new Error('Promise was unexpectedly fulfilled. Result: ' + result);
    } catch (error) {
      assert.isAbove(error.message.search('revert'), -1, 'Error containing "revert" must be returned');
    }
  });

  it("should fail to distribute INT token dividends from non-vendor account", async() => {
    try {
      let result = await share.distributeDividends(accounts[2], 1, {from: accounts[1]});
      throw new Error('Promise was unexpectedly fulfilled. Result: ' + result);
    } catch (error) {
      assert.isAbove(error.message.search('revert'), -1, 'Error containing "revert" must be returned');
    }
  });

  it("should fail to distribute INT token dividends to receiving account with 0 INS", async() => {
    try {
      let result = await share.distributeDividends(accounts[3], 1);
      throw new Error('Promise was unexpectedly fulfilled. Result: ' + result);
    } catch (error) {
      assert.isAbove(error.message.search('revert'), -1, 'Error containing "revert" must be returned');
    }
  });

  it("should fail to distribute zero INT token dividends to receiving account", async() => {
    try {
      await share.mint(accounts[3], oneToken.valueOf());
      let result = await share.distributeDividends(accounts[4], 0);
      throw new Error('Promise was unexpectedly fulfilled. Result: ' + result);
    } catch (error) {
      assert.isAbove(error.message.search('revert'), -1, 'Error containing "revert" must be returned');
    }
  });

  it("should be able to distribute 1xIN% INT tokens from one InShare (INS) and put them in the receiving account", async() => {
    await token.mint(accounts[0], BigNumber("5e+27").valueOf());
    await token.approve(InShare.address, oneToken.div(2).valueOf());
    await share.mint(accounts[1], oneToken.valueOf());
    let result = await share.distributeDividends(accounts[1], 1);
    let event = result.logs[2].args;
    assert.equal(event.receiver, accounts[1]);
    assert.equal(event.shares, oneToken.valueOf());
    assert.equal(event.value, oneToken.div(2).valueOf());
    let balance = await token.balanceOf.call(accounts[1]);
    assert.equal(balance.valueOf(), oneToken.div(2).valueOf(), "0.5 INT has landed in the receiving account");
  });

  it("should be able to rollout 10xIN% INT tokens from one InShare (INS) and put them in the receiving account", async() => {
    await share.mint(accounts[2], oneToken.valueOf());
    let result = await share.rolloutDividends(accounts[2]);
    let event = result.logs[2].args;
    assert.equal(event.receiver, accounts[2]);
    assert.equal(event.shares, oneToken.valueOf());
    assert.equal(event.value, oneToken.mul(5).valueOf());
    let balance = await token.balanceOf.call(accounts[2]);
    assert.equal(balance.valueOf(), oneToken.mul(5).valueOf(), "5 INT has landed in the receiving account");
  });

});