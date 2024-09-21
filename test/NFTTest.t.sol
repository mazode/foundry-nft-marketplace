// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/NFT.sol";
import "../src/Marketplace.sol";
import "../src/Auction.sol";

contract NFTTest is Test {
    NFT private nft;
    NFTMarketplace private marketplace;
    NFTAuction private auction;

    address private user1;
    address private user2;
    address private user3;

    function setUp() public {
        nft = new NFT(); // Deploy NFT Contract
        marketplace = new NFTMarketplace(); // // Deploy Marketplace Contract
        auction = new NFTAuction(); // // Deploy Auction Contract

        // Create user addresses
        user1 = address(0x1);
        user2 = address(0x2);
        user3 = address(0x3);

        // Mint an NFT to user1
        vm.startPrank(user1); // Start impersonating user1
        nft.mintNFT(user1);
        vm.stopPrank(); // Stop impersonating user1
    }

    // Test the listing and buying functionality in marketplace
    function testListAndBuyNFT() public {
        // User1 lists an NFT for sale
        vm.startPrank(user1);
        uint256 tokenId = nft.mintNFT(user2); // Mint NFT to user1
        nft.approve(address(marketplace), tokenId); // Approve marketplace to transfer the nft

        marketplace.listNFT(address(nft), tokenId, 1 ether, 500); // List NFT for 1 ether with 5% royalty
        vm.stopPrank();

        // User2 buys the NFT
        vm.startPrank(user2);
        marketplace.buyNFT{value: 1 ether}(address(nft), tokenId);
        vm.stopPrank();

        // Check that User2 now owns the NFT
        assertEq(nft.ownerOf(tokenId), user2);
    }

    // Testing Listing and checking Royalty distribution
    function testRoyaltiesTransfer() public {
        // User1 lists an NFT for sale
        vm.startPrank(user1);
        uint256 tokenId = nft.mintNFT(user1); // Mint NFT to User1
        nft.approve(address(nft), tokenId); // Approve marketplace to transfer the NFT

        marketplace.listNFT(address(nft), tokenId, 1 ether, 500); // List NFT for 1 ether with 5% royalty
        vm.stopPrank();

        // User2 buys the NFT
        vm.startPrank(user2);
        marketplace.buyNFT{value: 1 ether}(address(nft), tokenId);
        vm.stopPrank();

        // Check Royalty Distribution
        uint256 expectedSellerAmount = 0.95 ether; // Seller should get 95% royalty
        uint256 expectedCreatorAmount = 0.05 ether; // Creator should get 5% royalty

        assertEq(marketplace.balances(user1), expectedSellerAmount);
        assertEq(marketplace.balances(nft.creatorOf(tokenId)), expectedCreatorAmount);
    }

    // Test Creating and Bidding in an Auction
    function testCreateAndBidAuction() public {
        // User1 creates an auction
        vm.startPrank(user1);
        uint256 tokenId = nft.mintNFT(user1);
        nft.approve(address(auction), tokenId); // User1 approves the auction contract
        auction.createAuction(address(nft), tokenId, 1 ether, 1 hours); // Minimum Bid is 1 ETH
        vm.stopPrank();

        // User2 places a bid
        vm.startPrank(user2);
        auction.bid{value: 1.5 ether}(address(nft), tokenId); // User2 bids 1.5 ETH
        vm.stopPrank();

        // User3 places a higher bid
        vm.startPrank(user3);
        auction.bid{value: 2 ether}(address(nft), tokenId); // User3 bids 2 ETH
        vm.stopPrank();

        // Fast-forward time to end the auction
        vm.warp(block.timestamp + 1 hours + 1);

        // End the Auction
        vm.startPrank(user1);
        auction.endAuction(address(nft), tokenId);
        vm.stopPrank();

        // Ensure User3 is now the owner of the NFT
        assertEq(nft.ownerOf(tokenId), user3);

        // Check that User1 (seller) receives the highest bid (2 ETH)
        assertEq(auction.balances(user1), 2 ether);
    }
}
