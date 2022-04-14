// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const Linklist = await ethers.getContractFactory("Linklist");
  const linkList = await Linklist.deploy();

  const Web3Entry = await ethers.getContractFactory("Web3Entry");
  const web3Entry = await Web3Entry.deploy();

  const UIDataProvider = await ethers.getContractFactory("UIDataProvider");
  const uiDataProvider = await UIDataProvider.deploy(web3Entry.address);

  await linkList.deployed();
  await web3Entry.deployed();
  await uiDataProvider.deployed();

  await linkList.initialize("Link List Token", "LLT", web3Entry.address);
  await web3Entry.initialize("Web3 Entry Profile", "WEP", linkList.address);

  console.log("Web3 Entry deployed to:", web3Entry.address);
  console.log("UIDataProvider deployed to:", uiDataProvider.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
