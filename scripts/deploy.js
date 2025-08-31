// scripts/deploy.js
async function main() {
  const [deployer] = await ethers.getSigners();
  
  // Deploy NFT
  const NFT = await ethers.getContractFactory("MyNFT");
  const nft = await NFT.deploy();
  
  // Deploy Factory (with proxy)
  const Factory = await ethers.getContractFactory("AuctionFactory");
  const factory = await upgrades.deployProxy(Factory, [], { initializer: 'initialize' });
  
  console.log("NFT deployed to:", nft.address);
  console.log("Factory deployed to:", factory.address);
}