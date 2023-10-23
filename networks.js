require("dotenv").config();

const PRIVATE_KEY = process.env.PRIVATE_KEY;

const networks = {
  lineaTestnet: {
    url: "https://rpc.goerli.linea.build",
    gasPrice: undefined,
    accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
    verifyApiKey: process.env.LINEASCAN_API_KEY || "UNSET",
    chainId: 59140,
    nativeCurrencySymbol: "ETH",
    WAIT_BLOCK_CONFIRMATIONS: 3,
  },
  jolnirTestnet: {
    url: "https://rpc.jolnir.taiko.xyz",
    gasPrice: undefined,
    accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
    verifyApiKey: "UNSET",
    chainId: 167007,
    nativeCurrencySymbol: "ETH",
    WAIT_BLOCK_CONFIRMATIONS: 3,
  },
  mantleTestnet: {
    url: "https://rpc.testnet.mantle.xyz/",
    gasPrice: undefined,
    accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
    verifyApiKey: process.env.ETHERSCAN_API_KEY || "UNSET",
    chainId: 5001,
    nativeCurrencySymbol: "ETH",
    WAIT_BLOCK_CONFIRMATIONS: 3,
  },
  scrollTestnet: {
    url: "https://sepolia-rpc.scroll.io/",
    gasPrice: undefined,
    accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
    verifyApiKey: "UNSET",
    chainId: 534351,
    nativeCurrencySymbol: "ETH",
    WAIT_BLOCK_CONFIRMATIONS: 3,
  },
  klaytnTestnet: {
    url: "https://api.baobab.klaytn.net:8651",
    gasPrice: undefined,
    accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
    verifyApiKey: "UNSET",
    chainId: 1001,
    nativeCurrencySymbol: "KLAY",
    WAIT_BLOCK_CONFIRMATIONS: 3,
  },
};

module.exports = {
  networks,
};
