require("@nomiclabs/hardhat-waffle");
require("dotenv").config();

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
  solidity: {
    version: "0.8.4",
    settings: {
      optimizer: {
        enabled: true,
      }
    }
  },
  paths: {
    artifacts: './artifacts'
  },
  defaultNetwork: "binance_testnet",
  networks: {
    hardhat: {},
    binance_testnet: {
      url: `https://data-seed-prebsc-1-s1.binance.org:8545`,
      network_id:97,
      allowUnlimitedContractSize: true,
      accounts: [`0x${process.env.PRIVATEKEY}`]
    },
  },
};