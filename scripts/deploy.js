// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const Chunky  = await hre.ethers.getContractFactory("CCCT");
  const ChunkyCow = await Chunky.deploy();
  await ChunkyCow.deployed();
  console.log("Deployed  Address of ChunkyCow:", ChunkyCow.address);


const ChunkyNFT = await hre.ethers.getContractFactory("CCCTNFT");
const NFT = await ChunkyNFT.deploy();
await NFT.deployed();
console.log("Deployed Address of NFT:", NFT.address);
//0xDEEF2561192F947DAcfF06cDf8D719DCC0b1eF16
//0x2cc548421E78e436A67092c72eA557a716355A0D

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
