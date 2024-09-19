// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarketplace is ReentrancyGuard, Ownable {
    struct Listing {
        address seller;
        uint256 price;
    }

    // Mapping from NFT contract address -> tokenId -> listing details
    mapping(address => mapping(uint256 => Listing)) public listings;

    // Event for listing creation
    event NFTListed(address indexed nftAddress, uint256 indexed tokenId, address indexed seller, uint256 price);
    
    // Event for NFT purchase
    event NFTSold(address indexed nftAddress, uint256 indexed tokenId, address indexed buyer, uint256 price);
    
    // Function to list an NFT for sale
    function listNFT(address nftAddress, uint256 tokenId, uint256 price) external nonReentrant {
        require(price > 0, "Price must be greater than zero");
        
        IERC721 nft = IERC721(nftAddress);
        require(nft.ownerOf(tokenId) == msg.sender, "You are not the owner of this NFT");
        require(nft.isApprovedForAll(msg.sender, address(this)) || nft.getApproved(tokenId) == address(this),
            "Marketplace not approved to transfer NFT");

        listings[nftAddress][tokenId] = Listing(msg.sender, price);
        emit NFTListed(nftAddress, tokenId, msg.sender, price);
    }

    // Function to buy an NFT
    function buyNFT(address nftAddress, uint256 tokenId) external payable nonReentrant {
        Listing memory listedItem = listings[nftAddress][tokenId];
        require(listedItem.price > 0, "This NFT is not listed for sale");
        require(msg.value >= listedItem.price, "Insufficient funds to purchase NFT");

        // Transfer funds to the seller
        payable(listedItem.seller).transfer(listedItem.price);

        // Transfer NFT to the buyer
        IERC721(nftAddress).safeTransferFrom(listedItem.seller, msg.sender, tokenId);

        // Clean up the listing
        delete listings[nftAddress][tokenId];

        emit NFTSold(nftAddress, tokenId, msg.sender, listedItem.price);
    }

    // Function to cancel an NFT listing
    function cancelListing(address nftAddress, uint256 tokenId) external nonReentrant {
        Listing memory listedItem = listings[nftAddress][tokenId];
        require(listedItem.seller == msg.sender, "You are not the seller");

        // Clean up the listing
        delete listings[nftAddress][tokenId];

        emit NFTListed(nftAddress, tokenId, address(0), 0);
    }

    // Optional: Function to update marketplace fees (if applicable)
    function withdrawFees() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
