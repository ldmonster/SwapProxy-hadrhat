const { expect } = require("chai");
const { ethers } = require("hardhat");
const myAddress = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";

const ShadowCloneArtifact = require('../artifacts/contracts/ShadowClone.sol/ShadowClone.json');

describe("Greeter", function () {

  // it("Should return the new greeting once it's changed", async function () {
  //   const ShadowClone = await ethers.getContractFactory("ShadowClone");
  //   const shadowClone = await ShadowClone.deploy();
  //   await shadowClone.deployed();
  //   console.log(shadowClone.address);
  //   const network = await ethers.getDefaultProvider().getNetwork();
  //   console.log("Network chain id=", network.chainId);

  // });

  it("Should deploy contract", async function () {
    const [signer] = await ethers.getSigners();
    const ShadowCloneFactory = await ethers.getContractFactory("ShadowCloneFactory");
    const shadowCloneFactory = await ShadowCloneFactory.deploy();
    await shadowCloneFactory.deployed();
    console.log(shadowCloneFactory.address);
    let receipt = await shadowCloneFactory.createShadowCloner();
    let result = await receipt.wait();
    const shadowCloneAddress = await shadowCloneFactory.GetShadowCloner(signer.address);

    const shadowCloneContract = new ethers.Contract(
      shadowCloneAddress,
      ShadowCloneArtifact.abi,
      signer
    );

    console.log(await shadowCloneContract.factory());
    console.log(await shadowCloneContract.owner());
  });
});
