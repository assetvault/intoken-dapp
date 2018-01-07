const Gateway = artifacts.require("InbotMediatorGateway");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(Gateway, accounts[1]);
};
