// File: src/NFTAuction.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./NFT.sol";

contract NFTAuction {
    struct Auction {
        address seller;
        uint256 minBid;
        uint256 highestBid;
        address highestBidder;
        uint256 endTime;
        bool isActive;
    }

    mapping(address => mapping(uint256 => Auction)) public auctions;
    mapping(address => uint256) public balances;

    event AuctionCreated(address indexed nftAddress, uint256 indexed tokenId, uint256 minBid, uint256 endTime);
    event NewBid(address indexed nftAddress, uint256 indexed tokenId, address indexed bidder, uint256 amount);
    event AuctionEnded(address indexed nftAddress, uint256 indexed tokenId, address winner, uint256 amount);

    function createAuction(address nftAddress, uint256 tokenId, uint256 minBid, uint256 duration) external {
        NFT nft = NFT(nftAddress);
        require(nft.ownerOf(tokenId) == msg.sender, "Not the owner");
        require(nft.getApproved(tokenId) == address(this), "Auction contract not approved");

        auctions[nftAddress][tokenId] = Auction(msg.sender, minBid, 0, address(0), block.timestamp + duration, true);

        emit AuctionCreated(nftAddress, tokenId, minBid, block.timestamp + duration);
    }

    function bid(address nftAddress, uint256 tokenId) external payable {
        Auction storage auction = auctions[nftAddress][tokenId];
        require(auction.isActive, "Auction not active");
        require(block.timestamp < auction.endTime, "Auction ended");
        require(msg.value > auction.highestBid, "Bid is too low");

        // Refund previous highest bidder
        if (auction.highestBid > 0) {
            balances[auction.highestBidder] += auction.highestBid;
        }

        auction.highestBid = msg.value;
        auction.highestBidder = msg.sender;

        emit NewBid(nftAddress, tokenId, msg.sender, msg.value);
    }

    function endAuction(address nftAddress, uint256 tokenId) external {
        Auction storage auction = auctions[nftAddress][tokenId];
        require(auction.isActive, "Auction not active");
        require(block.timestamp >= auction.endTime, "Auction still ongoing");
        require(auction.seller == msg.sender, "Only seller can end auction");

        auction.isActive = false;

        if (auction.highestBid > 0) {
            // Transfer NFT to highest bidder
            NFT nft = NFT(nftAddress);
            nft.transferFrom(auction.seller, auction.highestBidder, tokenId);

            // Transfer the winning bid amount to the seller
            balances[auction.seller] += auction.highestBid;
        }

        emit AuctionEnded(nftAddress, tokenId, auction.highestBidder, auction.highestBid);
    }

    // Withdraw balance
    function withdrawBalance() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No balance to withdraw");

        balances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}
