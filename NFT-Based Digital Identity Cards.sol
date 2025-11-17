// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title NFT-Based Digital Identity Cards
 * @dev Each user can mint a unique, verifiable Digital Identity NFT
 */
contract DigitalIdentity is ERC721URIStorage, Ownable {
    uint256 public tokenCount;

    // Mapping from address to boolean to track if an identity NFT has already been minted
    mapping(address => bool) public hasIdentity;

    constructor() ERC721("DigitalIdentity", "DID") Ownable(msg.sender) {}


    /**
     * @dev Mint a new Digital Identity NFT (one per address)
     * @param tokenURI The metadata URI containing identity data
     */
    function mintIdentity(string memory tokenURI) public {
        require(!hasIdentity[msg.sender], "Identity already minted");
        tokenCount += 1;
        _safeMint(msg.sender, tokenCount);
        _setTokenURI(tokenCount, tokenURI);
        hasIdentity[msg.sender] = true;
    }

    /**
     * @dev Get the identity token ID for a given address
     * @param user The address to query
     */
    function getIdentityId(address user) public view returns (uint256) {
        require(hasIdentity[user], "No identity for user");
        for(uint256 i = 1; i <= tokenCount; i++) {
            if(ownerOf(i) == user) return i;
        }
        revert("Identity NFT not found");
    }

    /**
     * @dev Revoke (burn) an identity NFT (by contract owner or the user)
     * @param tokenId The identity NFT token ID to burn
     */
    function burnIdentity(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender || owner() == msg.sender, "Not authorized");
        address user = ownerOf(tokenId);
        _burn(tokenId);
        hasIdentity[user] = false;
    }
}
