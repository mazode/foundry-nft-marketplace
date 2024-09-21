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
}
