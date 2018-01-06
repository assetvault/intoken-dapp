const InToken = artifacts.require("InToken");
const InShare = artifacts.require("InShare");
const InScore = artifacts.require("InScore");
const InbotProxy = artifacts.require("InbotProxy");
const InbotMediatorGateway = artifacts.require("InbotMediatorGateway");

module.exports = function(deployer) {
  deployer.deploy(
  	InbotProxy, 
  	InToken.address, 
  	InShare.address, 
  	InScore.address,
  	InbotMediatorGateway.address
  ).then(function() {
  	InToken.at(InToken.address).setProxy(InbotProxy.address);
  	InShare.at(InShare.address).setProxy(InbotProxy.address);
  	InScore.at(InScore.address).setProxy(InbotProxy.address);
  	InbotMediatorGateway.at(InbotMediatorGateway.address).setProxy(InbotProxy.address);
  });
};
