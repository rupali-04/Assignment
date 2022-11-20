// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts@4.6.0/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.6.0/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts@4.6.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.6.0/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts@4.6.0/token/ERC721/utils/ERC721Holder.sol";

contract FractionalizedNFT is ERC20, Ownable, ERC20Permit, ERC721Holder {
    IERC721 public collection;
    uint256 public tokenId;
    bool public initialized = false;
    bool public forSale = false;
    uint256 public salePrice;
    bool public canRedeem = false;
    string public n;
    string public sym;

    constructor( string memory tokenName,
        string memory tokenSymbol) ERC20(n, sym) ERC20Permit(n) {
            n = tokenName;
            sym = tokenSymbol;
        }

        // This function helps to mint ERC20 token for given NFTs token

    function initialize(address _collection, uint256 _tokenId, uint256 _amount) external onlyOwner {
        require(!initialized, "Already initialized");
        require(_amount > 0, "Amount needs to be more than 0");
        collection = IERC721(_collection);
        collection.safeTransferFrom(msg.sender, address(this), _tokenId);
        tokenId = _tokenId;
        initialized = true;
        _mint(msg.sender, _amount);
    }

// This function helps you put your NFTs onSale
    function putForSale(uint256 price) external onlyOwner {
        salePrice = price;
        forSale = true;
    }

// This function helps you to sell your NFTs
    function purchase() external payable {
        require(forSale, "Not for sale");
        require(msg.value >= salePrice, "Not enough ether sent");
        collection.transferFrom(address(this), msg.sender, tokenId);
        forSale = false;
        canRedeem = true;
    }

// This function helps you to burn your ERC20 token to redeem your price (NFTs sell price) but this will only work when your nft is sold
    function redeem(uint256 _amount) external {
        require(canRedeem, "Redemption not available");
        uint256 totalEther = address(this).balance;
        uint256 toRedeem = _amount * totalEther / totalSupply();

        _burn(msg.sender, _amount);
        payable(msg.sender).transfer(toRedeem);
    }
}