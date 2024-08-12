/**
 * DESCRIPTION:
 * This contract inherits from a standard contract for soulbound tokens (ERC5192)
 * Unlike ERC721 tokens soulbound tokens aren't allowed to be transfered
 * Hence, for all transfer functions we add the 'checkLock' modifier defined in ERC5192
 * Currently, there's no implementation of ERC5192 from openzeppelin
 * -> using an implementation by the creator of IERC5192: https://github.com/attestate/ERC5192/tree/main
 */

// EIP-5192: https://eips.ethereum.org/EIPS/eip-5192
// IERC5192 discussion: https://ethereum-magicians.org/t/final-eip-5192-minimal-soulbound-nfts/9814

// NOTE:
// 1. Depending on the version of openzeppelin & solc there might be a need to override safeTransferFrom and _burn

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC5192} from "./ERC5192.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract FairAidDID is ERC5192, ERC721URIStorage, Ownable(msg.sender) {

    uint256 private _tokenId;
    // isLocked set to true to prevent transfers of NFTs
    bool private _isLocked = true;
    mapping(uint256 _tokenId => string) private _tokenURIs;
    // Stores a timestamp with DID expiration date
    mapping(uint256 _tokenId => uint256) private _expirationTime;
    mapping(address => uint256) private _hasMinted;
    mapping(uint256 => address) private _owners;

    constructor() ERC5192("FairAidDID", "DID", _isLocked) {
    }

    // Don't remember why I need this function
    // Think about removing it
    function _deployer()
        private
        view 
        returns(address)
    {
        return msg.sender;
    }

    // Check that a DID esists
    function _requiresOwned(uint256 tokenId) 
        private
        view
        returns(bool) 
    {
        return(_owners[tokenId] != address(0));
    }

    // Find tokenId of a DID owned by an owner  
    function findDID(address owner)
        public
        view
        returns(uint256)
    {
        require(_hasMinted[owner]!=0, "This DID doesn't exist.");
        require(checkExpired(_hasMinted[owner])==false, "This DID has expired!");
        return _hasMinted[owner];
    }

    // Find an owner of a DID
    function ownerOf(uint256 tokenId)
        public
        view
        override(IERC721, ERC721)
        returns(address)
    {
        require(_requiresOwned(tokenId)==true, "The DID doesn't exist!");
        require(checkExpired(tokenId)==false, "This DID has expired!");
        return _owners[tokenId];
    }

    // Check if DID has expired
    function checkExpired(uint256 tokenId)
        public
        view
        returns(bool)
    {
        require(_requiresOwned(tokenId)==true, "The DID doesn't exist!");
        return(block.timestamp >= _expirationTime[tokenId]);
    }    

    // Find a DID's expiration date 
    function expiresWhen(uint256 tokenId)
        public
        view
        returns(uint256)
    {
        require(_requiresOwned(tokenId)==true, "The DID doesn't exist!");
        require(checkExpired(tokenId)==false, "This DID has expired!");
        return _expirationTime[tokenId];
    }

    // Use to fetch metadata to view a DID
    function tokenURI(uint256 tokenId) 
        public
        view 
        override(ERC721, ERC721URIStorage) 
        returns(string memory) 
    {
        require(_requiresOwned(tokenId)==true, "The DID doesn't exist!");
        require(checkExpired(tokenId)==false, "This DID has expired!");
        return _tokenURIs[tokenId];
    }

    // Used only during minting
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) 
        internal
        override(ERC721URIStorage) 
    {
        _tokenURIs[tokenId] = _tokenURI;
    }

    // For updating URIs
    function updateTokenURI(uint256 tokenId, string memory _tokenURI)
        public
        onlyOwner
    {   
        require(_requiresOwned(tokenId)==true, "The DID doesn't exist!");
        require(checkExpired(tokenId)==false, "This DID has expired!");
        _setTokenURI(tokenId, _tokenURI);
    }    

    // Function for issuing DIDs
    function mintDID(address to, string memory _tokenURI)
        public
        onlyOwner
        {
            require(_hasMinted[to]==0, "This address already has an ID.");

            _tokenId++;
            
            _safeMint(to, _tokenId);

            _hasMinted[to] = _tokenId;

            _owners[_tokenId] = to;
            
            _setTokenURI(_tokenId, _tokenURI);

            _expirationTime[_tokenId] = block.timestamp + 157788000;
        }

    // Burn a DID (sends it to address(0))
    function burnDID(uint256 tokenId)
        public 
        onlyOwner
    {
        require(_requiresOwned(tokenId)==true, "The DID doesn't exist!");
        _hasMinted[_owners[tokenId]] = 0;
        _owners[tokenId] = address(0);
        _expirationTime[tokenId] = 0;
        _setTokenURI(tokenId, "Doesn't exist.");
        _burn(tokenId);
    }

    // Don't allow approvals 
    function approve(address approved, uint256 tokenId) 
        public 
        override(IERC721, ERC721, ERC5192) 
        onlyOwner
        checkLock
    {
        require(_requiresOwned(tokenId)==true, "The DID doesn't exist!");
        require(checkExpired(tokenId)==false, "This DID has expired!");
        super.approve(approved, tokenId);
    }

    // Don't allow transfers (checkLock is set to true
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) 
        public 
        override(IERC721, ERC721, ERC5192) 
        onlyOwner
        checkLock 
    {
        require(_requiresOwned(tokenId)==true, "The DID doesn't exist!");
        require(checkExpired(tokenId)==false, "This DID has expired!");
        super.safeTransferFrom(from, to, tokenId, data);
    }

    // Don't allow transfers (checkLock is set to true)
    function transferFrom(address from, address to, uint256 tokenId)
        public
        override(IERC721, ERC721, ERC5192) 
        onlyOwner
        checkLock
    {
        require(_requiresOwned(tokenId)==true, "The DID doesn't exist!");
        require(checkExpired(tokenId)==false, "This DID has expired!");
        super.transferFrom(from, to, tokenId);
    }

    // Don't allow approvals
    function setApprovalForAll(address operator, bool approved)
        public
        override(IERC721, ERC721, ERC5192)
        onlyOwner
        checkLock
    {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    // Don't allow ownership transfer
    function transferOwnership(address newOwner) 
        public 
        virtual 
        onlyOwner 
        checkLock
        override(Ownable)
    {
        _transferOwnership(newOwner);
    }

    // Returns interface id (allows other contracts to query which IERC is implemented)
    function supportsInterface(bytes4 interfaceId) 
        public 
        view 
        virtual 
        override(ERC5192, ERC721URIStorage)
        returns(bool) 
    {
        return
            interfaceId == type(ERC5192).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}

