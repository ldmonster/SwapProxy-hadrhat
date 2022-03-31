const hre = require("hardhat");

const ShadowCloneArtifact = require('../artifacts/contracts/ShadowClone.sol/ShadowClone.json');

async function main() {
  const [signer] = await ethers.getSigners();
  const shadowCloneAddress = "0x4ed7c70F96B99c776995fB64377f0d4aB3B0e1C1";
  const provider = new ethers.providers.JsonRpcProvider("http://127.0.0.1:8545");


  const ShadowClone = await hre.ethers.getContractFactory("ShadowClone");
  const shadowClone = await ShadowClone.deploy();
  console.log(shadowClone.deployTransaction.data);

  await shadowClone.deployed();

  console.log("ShadowClone deployed to:", shadowClone.address);

  // const tx = await signer.sendTransaction({
  //   to: shadowCloneAddress,
  //   value: ethers.utils.parseEther("1.0")
  // }); 

  // const shadowCloneContract = new ethers.Contract(
  //   shadowCloneAddress,
  //   ShadowCloneArtifact.abi,
  //   signer
  // );

  // let balance = await provider.getBalance(shadowCloneAddress);
  // console.log(balance);
  // console.log(signer.address);
  
  // let owner = await shadowCloneContract.owner();
  // console.log(owner);

  // const result = await shadowCloneContract.EmmergencyWithdrawAll();
  // const receip = await result.wait();
  // balance = await provider.getBalance(shadowCloneAddress);
  // console.log(balance);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
