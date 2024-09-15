// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is ERC721, Ownable(msg.sender) {
    uint256 private _tokenIdCounter;

    constructor() ERC721("CoolNFT", "CNFT") {}

    function mint(address recipient, string memory tokenURI) public onlyOwner returns (uin256) {
        uin256 currentTokenId = _tokenIdCounter;
        ++_tokenIdCounter;
        _safeMint(recipient, currentTokenId);
        _setTokenURI(currentTokenId, tokenURI);
        return currentTokenId;
    }
}
