const hre = require("hardhat");

async function main() {
  const NFTMarket = await ethers.getContractFactory("NFTMarket");
  const nft_market = await NFTMarket.deploy();
  await nft_market.deployed();

  console.log("NFTMarket contract is deployed to: ", nft_market.address);

  const NFT = await ethers.getContractFactory("NFT");
  const nft = await NFT.deploy(nft_market.address);
  await nft.deployed();

  console.log("NFT contract is deployed to: ", nft.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
