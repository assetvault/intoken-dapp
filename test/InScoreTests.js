const BigNumber = require("bignumber.js");
const InScore = artifacts.require("InScore");
const full100PercentScore = BigNumber("1e+18");

contract("InScore", function(accounts) {
  let score;

  before(async() => {
    score = await InScore.deployed();
  });

  it("should have 50% default IN% in any account when deployed", async() => {
    let accountScore = await score.getScore.call(accounts[0]);
    assert.equal(accountScore.valueOf(), full100PercentScore.div(2).valueOf(), "50% IN% was in the account");
  });

  it("should fail to set the default IN% from non-admin account", async() => {
    try {
      let result = await score.setDefaultScore(full100PercentScore, {from: accounts[1]});
      throw new Error('Promise was unexpectedly fulfilled. Result: ' + result);
    } catch (error) {
      assert.isAbove(error.message.search('revert'), -1, 'Error containing "revert" must be returned');
    }
  });

  it("should fail to increase IN% from non-admin account", async() => {
    try {
      let result = await score.scoreUp(accounts[0], {from: accounts[1]});
      throw new Error('Promise was unexpectedly fulfilled. Result: ' + result);
    } catch (error) {
      assert.isAbove(error.message.search('revert'), -1, 'Error containing "revert" must be returned');
    }
  });

  it("should fail to decrease IN% from non-admin account", async() => {
    try {
      let result = await score.scoreDown(accounts[0], {from: accounts[1]});
      throw new Error('Promise was unexpectedly fulfilled. Result: ' + result);
    } catch (error) {
      assert.isAbove(error.message.search('revert'), -1, 'Error containing "revert" must be returned');
    }
  });

  it("should be able to increase IN% from the admin account", async() => {
    await score.adminAddRole(accounts[1], "admin");
    await score.scoreUp(accounts[0], {from: accounts[1]});
    let accountScore = await score.getScore.call(accounts[0]);
    assert.equal(accountScore.valueOf(), full100PercentScore.div(10).mul(6).valueOf(), "60% IN% was in the account");
  });

  it("should not be able to increase IN% account beyond 200%", async() => {
    await score.setScore(accounts[0], full100PercentScore.mul(2).valueOf());
    await score.scoreUp(accounts[0], {from: accounts[1]});
    let accountScore = await score.getScore.call(accounts[0]);
    assert.equal(accountScore.valueOf(), full100PercentScore.mul(2).valueOf(), "200% IN% was in the account");
  });

  it("should fail to decrease IN% account beyond 0%", async() => {
    try {
      await score.setScore(accounts[0], 0);
      let result = await score.scoreDown(accounts[0]);
      throw new Error('Promise was unexpectedly fulfilled. Result: ' + result);
    } catch (error) {
      assert.isAbove(error.message.search('revert'), -1, 'Error containing "revert" must be returned');
    }
  });

});