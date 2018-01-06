module.exports = {
  authors: ["Vilen Jumutc <vilen@inbot.io>"],
  license: "MIT",
  networks: {
    development: {
      host: "localhost",
      port: 9545,
      network_id: "*" // match Truffle Develop
    },
    kovan: {
      host: "localhost",
      port: 8545,
      network_id: "42",
      gasPrice: 1000000000
    },
    devnet: {
      host: "localhost",
      port: 8545,
      network_id: "*"
    },
    live: {
      host: "localhost",
      port: 8545,
      network_id: "1"
    }
  }
};