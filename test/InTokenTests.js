const BigNumber = require("bignumber.js");
const InToken = artifacts.require("InToken");
const InScore = artifacts.require("InScore");
const totalCap = BigNumber("1e+28");
const oneINT = BigNumber("1e+18");

contract("InToken", function(accounts) {
  let token; 

  before(async() => {
    token = await InToken.deployed();
  });

  it("should have 0 INT in the owning account when deployed", async() => {
    let balance = await token.balanceOf.call(accounts[0]);
    assert.equal(balance.valueOf(), 0, "0 was in the owning account");
  });

  it("should be able to mint 10B INT and put them in the owning account", async() => {
    let result = await token.mint(accounts[0], totalCap.valueOf());
    let event1 = result.logs[0].args;
    assert.equal(event1.to, accounts[0]);
    assert.equal(event1.amount, totalCap.valueOf());
    let event2 = result.logs[1].args;
    assert.equal(event2.from, 0x0);
    assert.equal(event2.to, accounts[0]);
    assert.equal(event2.value, totalCap.valueOf());
    let balance = await token.balanceOf.call(accounts[0]);
    assert.equal(balance.valueOf(), totalCap.valueOf(), "10B INT has landed in the owning account");
  });

  it("should not be able to mint more than 10B INTs", async() => {
    try {
      await token.mint(accounts[0], totalCap.valueOf());
      throw new Error('Promise was unexpectedly fulfilled. Result: ' + result);
    } catch (error) {
      assert.isAbove(error.message.search('revert'), -1, 'Error containing "revert" must be returned');
    }
  });

  it("should fail to transfer to non-ERC223 compliant contract address", async() => {
    try {
      let result = await token.transfer(InScore.address, 1);
      throw new Error('Promise was unexpectedly fulfilled. Result: ' + result);
    } catch (error) {
      assert.isAbove(error.message.search('revert'), -1, 'Error containing "revert" must be returned');
    }
  });

  it("should allow account_1 to spend 1 INT", async() => {
    let result = await token.approve(accounts[1], oneINT.valueOf());
    let event = result.logs[0].args;
    assert.equal(event.owner, accounts[0]);
    assert.equal(event.spender, accounts[1]);
    assert.equal(event.value, oneINT.valueOf());
    let allowed = await token.allowance.call(accounts[0], accounts[1]);
    assert.equal(allowed, oneINT.valueOf());
  });

  it("should fail to transfer from account_1 because of insufficient funds", async() => {
    try {
      let result = await token.transfer(accounts[2], 1, {from: accounts[1]});
      throw new Error('Promise was unexpectedly fulfilled. Result: ' + result);
    } catch (error) {
      assert.isAbove(error.message.search('revert'), -1, 'Error containing "revert" must be returned');
    }
  });

  it("should fail to transfer from account_0 to non-ERC223 compliant contract address", async() => {
    try {
      let result = await token.transferFrom(accounts[0], InScore.address, oneINT.valueOf(), {from: accounts[1]});
      throw new Error('Promise was unexpectedly fulfilled. Result: ' + result);
    } catch (error) {
      assert.isAbove(error.message.search('revert'), -1, 'Error containing "revert" must be returned');
    }
  });

  it("should allow account_1 to transfer 1 INT to itself from account_0", async() => {
    let result = await token.transferFrom(accounts[0], accounts[1], oneINT.valueOf(), {from: accounts[1]});
    let event = result.logs[0].args;
    assert.equal(event.from, accounts[0]);
    assert.equal(event.to, accounts[1]);
    assert.equal(event.value, oneINT.valueOf());
    let balance = await token.balanceOf.call(accounts[1]);
    assert.equal(balance, oneINT.valueOf(), "1 INT in the account_2");
  });

  it("should burn all of the owner's tokens", async() => {
    let result = await token.burn(oneINT.valueOf(), {from: accounts[1]});
    let event = result.logs[0].args;
    assert(event.burner, accounts[1]);
    assert(event.value, oneINT.valueOf());
    let balance = await token.balanceOf.call(accounts[1]);
    assert.equal(balance.valueOf(), 0, "0 was in the owning account");
  });

  it("should fail to pause from non-admin account", async() => {
    try {
      let result = await token.pause({from: accounts[1]});
      throw new Error('Promise was unexpectedly fulfilled. Result: ' + result);
    } catch (error) {
      assert.isAbove(error.message.search('revert'), -1, 'Error containing "revert" must be returned');
    }
  });

  it("should fail to transfer once token is paused", async() => {
    let result = await token.pause();
    try {
      let result = await token.transfer(accounts[1], 1);
      throw new Error('Promise was unexpectedly fulfilled. Result: ' + result);
    } catch (error) {
      assert.isAbove(error.message.search('revert'), -1, 'Error containing "revert" must be returned');
    }
  });
});