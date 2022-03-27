const { expect } = require("chai");
const { ethers } = require("hardhat");

const routerAddress = '0xE592427A0AEce92De3Edee1F18E0157C05861564'; // all nets
const nonFungPosMngAddy = '0xC36442b4a4522E871399CD717aBDD847Ab11FE88'; // all nets
const wMaticAddress = '0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889'; // testnet
describe("Initial tests for tokenomics boilerplate", function(){
  before(async()=>{
    [owner, user1, user2, user3] = await ethers.getSigners();
    console.log(`Owner:${owner.address}`);
    console.log(`Users: ${user1},  ${user2}`);

    //Deploy Doll token
    const Doll = await ethers.getContractFactory("DollToken");
    const doll  =  await Doll.deploy();
    await doll.deployed();
    console.log(`Doll Token deployed to:${doll.address}`);
  
    //Deploy Main contract
    const mainContractCode = await hre.ethers.getContractFactory('MainContract');
    mainContract = await mainContractCode.deploy(doll.address,routerAddress,wMaticAddress);
    await mainContract.deployed();
    console.log(`Doll contract deployed to: ${mainContract.address}`);
  })

  it("Send some funds to the contract to buy some doll tokens", async()=>{
    const balance1 = await ethers.provider.getBalance(owner.address);
    console.log(`Balance1: ${balance1}`);
    await mainContract.connect(owner).doSomething({value:20000000000});
    const balance2 = await ethers.provider.getBalance(owner.address);
    console.log(`Balance1: ${balance1}`);
    expect(balance2).to.be.lt(balance1);
  })
})  
