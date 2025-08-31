// scripts/deploy.js
async function main() {
  const [deployer] = await ethers.getSigners();
  
  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());
  
  // Deploy NFT (需要传入 initialOwner 参数)
  const NFT = await ethers.getContractFactory("MyNFT");
  const nft = await NFT.deploy(deployer.address);
  await nft.deployed();
  
  // Deploy Factory (with proxy)
  const Factory = await ethers.getContractFactory("AuctionFactory");
  const factory = await upgrades.deployProxy(Factory, [], { initializer: 'initialize' });
  await factory.deployed();
  
  console.log("NFT deployed to:", nft.address);
  console.log("Factory deployed to:", factory.address);
  
  // Mint a test NFT
  await nft.mint(deployer.address);
  console.log("Minted NFT #1 to:", deployer.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });