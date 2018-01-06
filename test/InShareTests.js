const BigNumber = require("bignumber.js");
const InToken = artifacts.require("InToken");
const InShare = artifacts.require("InShare");
const oneINT = new BigNumber("1e+18");
const oneINS = new BigNumber("1e+5");

contract("InShare", function(accounts) {
  let token; 

  before(async() => {
    token = await InShare.deployed();
  });

  it("should have 0 INT in the owning account when deployed", async() => {
    let balance = await token.balanceOf.call(accounts[0]);
    assert.equal(balance.valueOf(), 0, "0 was in the owning account");
  });

  it("should be able to mint 1 INS and put them in the owning account", async() => {
    let result = await token.mint(accounts[0], oneINS.valueOf());
    let event1 = result.logs[0].args;
    assert.equal(event1.to, accounts[0]);
    assert.equal(event1.amount, oneINS.valueOf());
    let event2 = result.logs[1].args;
    assert.equal(event2.from, 0x0);
    assert.equal(event2.to, accounts[0]);
    assert.equal(event2.value, oneINS.valueOf());
    let balance = await token.balanceOf.call(accounts[0]);
    assert.equal(balance.valueOf(), oneINS.valueOf(), "1 INS has landed in the owning account");
  });

  it("should fail to transfer any INS from the beginning", async() => {
    try {
      let result = await token.transfer(accounts[1], oneINS.valueOf());
      throw new Error('Promise was unexpectedly fulfilled. Result: ' + result);
    } catch (error) {
      assert.isAbove(error.message.search('revert'), -1, 'Error containing "revert" must be returned');
    }
  });
});