// test/Auction.test.js
const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("NFT Auction Market", function() {
  let nft, factory, auction;
  let owner, seller, bidder;
  
  beforeEach(async function() {
    [owner, seller, bidder] = await ethers.getSigners();
    
    const NFT = await ethers.getContractFactory("MyNFT");
    nft = await NFT.deploy();
    
    const Factory = await ethers.getContractFactory("AuctionFactory");
    factory = await upgrades.deployProxy(Factory, [], { initializer: 'initialize' });
    
    await nft.mint(seller.address);
  });
  
  it("Should create auction", async function() {
    await nft.connect(seller).approve(factory.address, 1);
    const tx = await factory.connect(seller).createAuction(
      nft.address,
      1,
      ethers.utils.parseEther("1"),
      3600,
      ethers.constants.AddressZero, // ETH
      "0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419" // ETH/USD feed
    );
    
    const receipt = await tx.wait();
    const auctionAddress = receipt.events.find(e => e.event === "AuctionCreated").args.auction;
    auction = await ethers.getContractAt("Auction", auctionAddress);
    
    expect(await nft.ownerOf(1)).to.equal(auctionAddress);
  });
  
  it("Should place bid and end auction", async function() {
    // ... test implementation
  });
});