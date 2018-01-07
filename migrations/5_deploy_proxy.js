const InToken = artifacts.require("InToken");
const InShare = artifacts.require("InShare");
const InScore = artifacts.require("InScore");
const Gateway = artifacts.require("InbotMediatorGateway");
const InbotProxy = artifacts.require("InbotProxy");

module.exports = function(deployer) {
  deployer.deploy(
  	InbotProxy, 
  	InToken.address, 
  	InShare.address, 
  	InScore.address,
  	Gateway.address
  ).then(function() {
  	InToken.at(InToken.address).setProxy(InbotProxy.address);
  	InShare.at(InShare.address).setProxy(InbotProxy.address);
  	InScore.at(InScore.address).setProxy(InbotProxy.address);
  	Gateway.at(Gateway.address).setProxy(InbotProxy.address);
  });
};
