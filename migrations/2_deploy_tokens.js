const InToken = artifacts.require("InToken");
const InShare = artifacts.require("InShare");

module.exports = function(deployer) {
  deployer.deploy(InToken);
  deployer.deploy(InShare);
};
