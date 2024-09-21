// File: src/NFTMarketplace.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./NFT.sol";

contract NFTMarketplace {
    struct Listing {
        address seller;
        uint256 price;
    }

    struct RoyaltyInfo {
        address creator;
        uint256 royaltyPercentage; // Royalty percentage (e.g., 5% = 500)
    }

    // Mapping from NFT contract to tokenId to Listing
    mapping(address => mapping(uint256 => Listing)) public listings;

    // Mapping from NFT contract to tokenId to royalty info
    mapping(address => mapping(uint256 => RoyaltyInfo)) public royalties;

    mapping(address => uint256) public balances;

    event NFTListed(address indexed nftAddress, uint256 indexed tokenId, address indexed seller, uint256 price);
    event NFTPurchased(address indexed nftAddress, uint256 indexed tokenId, address indexed buyer, uint256 price);
    event ListingCancelled(address indexed nftAddress, uint256 indexed tokenId);

    // List an NFT for sale
    function listNFT(address nftAddress, uint256 tokenId, uint256 price, uint256 royaltyPercentage) external {
        require(price > 0, "Price must be greater than 0");

        NFT nft = NFT(nftAddress);
        require(nft.ownerOf(tokenId) == msg.sender, "Not the owner");
        require(nft.getApproved(tokenId) == address(this), "Marketplace not approved");

        listings[nftAddress][tokenId] = Listing(msg.sender, price);
        royalties[nftAddress][tokenId] = RoyaltyInfo(nft.creatorOf(tokenId), royaltyPercentage);

        emit NFTListed(nftAddress, tokenId, msg.sender, price);
    }

    // Purchase an NFT
    function buyNFT(address nftAddress, uint256 tokenId) external payable {
        Listing memory listing = listings[nftAddress][tokenId];
        require(listing.price > 0, "NFT not listed for sale");
        require(msg.value == listing.price, "Incorrect value sent");

        // Handle royalty payments
        RoyaltyInfo memory royalty = royalties[nftAddress][tokenId];
        uint256 royaltyAmount = (msg.value * royalty.royaltyPercentage) / 10000;
        uint256 sellerAmount = msg.value - royaltyAmount;

        balances[listing.seller] += sellerAmount;
        balances[royalty.creator] += royaltyAmount;

        // Transfer NFT to buyer
        NFT nft = NFT(nftAddress);
        nft.transferFrom(listing.seller, msg.sender, tokenId);

        // Remove the listing
        delete listings[nftAddress][tokenId];

        emit NFTPurchased(nftAddress, tokenId, msg.sender, listing.price);
    }

    // Cancel a listing
    function cancelListing(address nftAddress, uint256 tokenId) external {
        Listing memory listing = listings[nftAddress][tokenId];
        require(listing.seller == msg.sender, "Not the seller");

        delete listings[nftAddress][tokenId];

        emit ListingCancelled(nftAddress, tokenId);
    }

    // Withdraw balance
    function withdrawBalance() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No balance to withdraw");

        balances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}
