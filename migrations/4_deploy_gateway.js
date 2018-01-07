const InbotMediatorGateway = artifacts.require("InbotMediatorGateway");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(InbotMediatorGateway, accounts[1]);
};
