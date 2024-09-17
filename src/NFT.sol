// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC721, Ownable {
    uint256 private _tokenIds; // Local counter for token IDs
    mapping(uint256 => string) private _tokenURIs; // Mapping for token URIs

    constructor() ERC721("CoolNFT", "CNFT") {}

    // Function to mint a new NFT
    function mintNFT(address recipient, string memory tokenURI) public onlyOwner returns (uint256) {
        _tokenIds += 1; // Increment local counter

        uint256 newItemId = _tokenIds; // Assign new token ID
        _mint(recipient, newItemId); // Mint the token
        _setTokenURI(newItemId, tokenURI); // Set the token's metadata URI

        return newItemId;
    }

    // Internal function to set the token URI
    function _setTokenURI(uint256 tokenId, string memory tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = tokenURI;
    }

    // Function to retrieve token URI
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return _tokenURIs[tokenId];
    }
}
