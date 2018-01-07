const InToken = artifacts.require("InToken");
const InShare = artifacts.require("InShare");
const InScore = artifacts.require("InScore");
const Gateway = artifacts.require("InbotMediatorGateway");

module.exports = function(deployer, network, accounts) {
	InShare.at(InShare.address).adminAddRole(accounts[0], "vendor");
	InShare.at(InShare.address).adminAddRole(Gateway.address, "admin");
	InScore.at(InScore.address).adminAddRole(Gateway.address, "admin");
	InToken.at(InToken.address).adminAddRole(InShare.address, "admin");
};