// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./Auction.sol";

contract AuctionFactory is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    address[] public auctions;
    mapping(address => bool) public isAuction;
    
    event AuctionCreated(address indexed auction, address indexed seller);

    function initialize() public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    function createAuction(
        address nft,
        uint256 tokenId,
        uint256 minBid,
        uint256 duration,
        address paymentToken,
        address priceFeed
    ) external returns (address) {
        Auction auction = new Auction();
        auction.initialize(
            nft,
            tokenId,
            minBid,
            duration,
            paymentToken,
            priceFeed
        );
        
        auctions.push(address(auction));
        isAuction[address(auction)] = true;
        
        emit AuctionCreated(address(auction), msg.sender);
        return address(auction);
    }

    function getAllAuctions() external view returns (address[] memory) {
        return auctions;
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}
}