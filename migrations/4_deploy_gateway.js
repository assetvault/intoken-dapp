const InbotMediatorGateway = artifacts.require("InbotMediatorGateway");

module.exports = function(deployer, network, accounts) {
  const vault = accounts[1];
  deployer.deploy(InbotMediatorGateway, vault);
};
