// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract Auction is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    struct Bid {
        address bidder;
        uint256 amount;
        uint256 timestamp;
    }
    
    IERC721 public nft;
    uint256 public tokenId;
    address public seller;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public minBid;
    address public highestBidder;
    uint256 public highestBid;
    bool public ended;
    
    address public paymentToken; // ERC20 token address, address(0) for ETH
    AggregatorV3Interface internal priceFeed;
    
    mapping(address => Bid) public bids;
    
    event AuctionCreated(uint256 tokenId, uint256 startTime, uint256 endTime);
    event BidPlaced(address bidder, uint256 amount);
    event AuctionEnded(address winner, uint256 amount);

    function initialize(
        address _nft,
        uint256 _tokenId,
        uint256 _minBid,
        uint256 _duration,
        address _paymentToken,
        address _priceFeed
    ) public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
        
        nft = IERC721(_nft);
        tokenId = _tokenId;
        seller = msg.sender;
        minBid = _minBid;
        startTime = block.timestamp;
        endTime = block.timestamp + _duration;
        paymentToken = _paymentToken;
        priceFeed = AggregatorV3Interface(_priceFeed);
        
        nft.transferFrom(msg.sender, address(this), _tokenId);
        emit AuctionCreated(_tokenId, startTime, endTime);
    }

    function placeBid(uint256 amount) external payable {
        require(block.timestamp >= startTime && block.timestamp <= endTime, "Auction not active");
        require(amount >= minBid, "Bid too low");
        
        if (paymentToken == address(0)) {
            require(msg.value == amount, "ETH amount mismatch");
        } else {
            // ERC20 transfer handled by factory
        }
        
        if (amount > highestBid) {
            highestBid = amount;
            highestBidder = msg.sender;
        }
        
        bids[msg.sender] = Bid(msg.sender, amount, block.timestamp);
        emit BidPlaced(msg.sender, amount);
    }

    function endAuction() external {
        require(block.timestamp > endTime, "Auction not ended");
        require(!ended, "Auction already ended");
        
        ended = true;
        nft.transferFrom(address(this), highestBidder, tokenId);
        
        // Transfer funds to seller (handled by factory)
        emit AuctionEnded(highestBidder, highestBid);
    }

    function getPriceInUSD() public view returns (uint256) {
        (, int256 price,,,) = priceFeed.latestRoundData();
        uint256 adjustedPrice = uint256(price) * 10**10; // Convert to 18 decimals
        return highestBid * adjustedPrice / 1e18;
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}
}