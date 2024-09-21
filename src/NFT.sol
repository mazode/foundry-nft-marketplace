// File: src/MyNFT.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is ERC721, Ownable(msg.sender) {
    uint256 private _tokenIdCounter;

    // Mapping from token ID to the original creator's address
    mapping(uint256 => address) private _creators;

    constructor() ERC721("CoolNFT", "CNFT") {}

    // Mint a new NFT and assign it to the recipient
    function mintNFT(address recipient) external onlyOwner returns (uint256) {
        _tokenIdCounter += 1;
        uint256 newItemId = _tokenIdCounter;
        _mint(recipient, newItemId);
        _creators[newItemId] = msg.sender; // Store original creator
        return newItemId;
    }

    // Retrieve the original creator of a token
    function creatorOf(uint256 tokenId) external view returns (address) {
        return _creators[tokenId];
    }
}
