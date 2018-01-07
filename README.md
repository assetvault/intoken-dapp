<p align="center">
  <a href="http://intoken.org">
    <img src="https://docs.google.com/drawings/d/e/2PACX-1vSbArtseL0OtUZ6A8fl9hXD4qcm5JepJyUNi_xQiVpKO_e8osB1086JjUeu57R7mj6rPJRU-HuFOCr4/pub?w=421&h=384" alt="InToken" height="100px"/>
  </a>
</p>

# InToken Ðapp and Smart Contracts

Public repository for source code of the `InToken` \& `InShare` [ERC-20](https://theethereum.wiki/w/index.php/ERC20_Token_Standard)/223 tokens and associated Smart Contracts related to the ecosystem.

## Abstract

- `InToken` is a utility token for businesses to reward a community of people who make them introductions to customers. 

- `InShare` is a crypto-security that pays community members token dividends on regular intervals. `InShares` can be earned by making introductions to businesses who are listed as qualified vendors on the Inbot Ambassador platform.

- `InScore` is a smart contract that manages the compensation multiplier of Ambassadors. This is an automated way of enforcing good behavior of the community members.

- `Inbot Mediator Gateway` automates the processes of opening an intro bid, contracting the ambassador, mediating the result, and in case of successful delivery, automatically transferring the rewards to the ambassador's token address.

## Useful Information

Read more: [Whitepaper](https://docs.google.com/document/d/12siRqjuHIHelPS-NaVVZxnq4AJ1hGlDXoGo6DeVw51U/edit?usp=sharing)

Company website: [Inbot](https://inbot.io)

Software license: [MIT License](LICENSE)

## Main contracts
*  **InToken**

Serves as the main governing smart contaract for INT tokens. Allows to transfer, mint and burn `InTokens`. 

*  **InShare**

Serves as the main governing smart contaract for INS crypto-security. Designed to distribute and rollout dividents in terms of INT tokens to a community. Allows to transfer, mint and burn `InShares` but transfers are disabled at the deployment.  

*  **InScore (IN\%)**

Contract stores trust scores of ambassadors and vendors. Allows to increase or decrease scores for sibling contracts and admin users. 

*  **Inbot Mediator Gateway**

Serves and operates intro workflows. Contains transparently our business logics of rewarding ambassadors (and discouraging dishonest actors) for making introductions in terms of INT tokens and INS crypto-securities. 

## Prerequisites

* [Node.js](https://nodejs.org/en/download/) v9.3.0+
* [truffle](http://truffleframework.com/) v4.0.4+
* [ganache-cli](https://github.com/trufflesuite/ganache-cli) v6.0.3+
* [zeppelin-solidity](https://github.com/OpenZeppelin/zeppelin-solidity) v1.5.0+

## How to run tests

In separate terminal run next command:
```
ganache-cli
```

In terminal from the project folder run the following command:
```
truffle test
```

## How to deploy to mainnet

In separate terminal run your Ethereum node on `8545` port ([Parity](https://parity.io/), for example).

And in main terminal run the following command:

```
truffle migrate --network=live
```