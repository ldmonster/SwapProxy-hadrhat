require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.4",
};

const BSC_PRIVATE_KEY = "538df914d2dc721f5a40fd8b46f1ae9c749ca896ae5098f9d229420671939399";
/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.4",
  networks: {
    // hardhat: {
    //   forking: {
    //     url: "https://eth-mainnet.alchemyapi.io/v2/<key>",
    //   }
    // },
    bscTestnet: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
      chainId: 97,
      gasPrice: 20000000000,
      accounts: [`${BSC_PRIVATE_KEY}`]
    },
  },
  etherscan: {
    apiKey: {
      bscTestnet: "VBT1ZUXRFBP3X3KNFUC8GPAC1RPXN8M93H",
      rinkeby: "Y3JKSV8311M222M2CHU9H7CT5XCJI45MWR",
    }
  }
};