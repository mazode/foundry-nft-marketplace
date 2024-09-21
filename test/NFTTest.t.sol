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
}
