// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const { ethers } = require("hardhat");
const hre = require("hardhat");
const routerAddress ="0x9ac64cc6e4415144c455bd8e4837fea55603e5c3";
const wBnbAddress = '0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd';

const ethAmount = ethers.utils.parseEther('30');
const dollTokenAmount = ethers.utils.parseEther('300000');
const stakingAmount = ethers.utils.parseEther('300000');
const stakingTimeFrameBlocks = ethers.BigNumber.from('2102400');

async function main() {
  [owner] = await ethers.getSigners();
  console.log(`Owner: ${owner.address}`);
  await hre.run('compile');

  //Deploy Doll Token
  const Doll = await hre.ethers.getContractFactory("DollToken");
  const doll = await Doll.deploy();
  await doll.deployed();
  console.log("DollToken deployed to:", doll.address);
  //Deploy Main Contract
  const mainContractCode = await hre.ethers.getContractFactory("MainContract");
  const mainContract = await mainContractCode.deploy(doll.address,routerAddress,wBnbAddress);
  await mainContract.deployed();
  console.log("Main Contract deployed to:", mainContract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
