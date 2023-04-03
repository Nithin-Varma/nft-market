//SPDX-License-Identifier:MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTMarket is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private TotalItems;
    Counters.Counter private SoldItems;

    address private owner;

    uint listingPrice = 0.0001 ether;
   // This is paid by the seller when listing an NFT.

    constructor() {
        owner = payable(msg.sender);
    }

    struct MarketDetails {
        uint Id;
        uint tokenId;
        address NFTAddress;
        address payable seller;
        address payable owner;
        uint price;
        bool SoldOut;
    }

    mapping(uint256 => MarketDetails) private idToMarketDetails;

    event MarketCreated(uint indexed Id, uint indexed tokenId, 
                        address indexed NFTAddress, address seller,
                        address owner, uint price, bool SoldOut);

    function getlistingprice() public view returns(uint) {
        return listingPrice;
    }

    function CreateMarketItem(uint tokenId, address NFTAddress, uint price) 
              public payable nonReentrant {
                  require(price>0, "price should be more than zero.");
                  require(msg.value == listingPrice, "price should be equal to the listingPrice.");

                  TotalItems.increment();
                  uint Id = TotalItems.current();

                  idToMarketDetails[Id] = MarketDetails(
                      Id,
                      tokenId,
                      NFTAddress,
                      payable(msg.sender),
                      payable(address(0)),
                      price,
                      false
                  );
                  IERC721(NFTAddress).transferFrom(msg.sender, address(this), tokenId);
                  emit MarketCreated(
                      Id,
                      tokenId,
                      NFTAddress,
                      msg.sender,
                      address(0),
                      price,
                      false
                      
                  );

    }


    function createMarketforSale(address NFTAddress, uint Id)
            public payable nonReentrant {
                uint price = idToMarketDetails[Id].price;
                uint tokenId = idToMarketDetails[Id].tokenId;
                require(msg.value == price);

                idToMarketDetails[Id].seller.transfer(msg.value);
                IERC721(NFTAddress).transferFrom(address(this), msg.sender, tokenId);

                idToMarketDetails[Id].owner = payable(msg.sender);
                idToMarketDetails[Id].SoldOut = true;

                SoldItems.increment();
                payable(owner).transfer(listingPrice);
    }

    function fetchAvailableItems() public view returns(MarketDetails[] memory) {
        uint itemCount = TotalItems.current();
        uint unsoldItemsCount = TotalItems.current() - SoldItems.current();
        uint Index = 0;

        MarketDetails[] memory items = new MarketDetails[](unsoldItemsCount);

        for(uint i=0; i<itemCount; i++) {
            if(idToMarketDetails[i+1].owner == address(0)) {
                uint current_id = idToMarketDetails[i+1].Id;
                MarketDetails storage currentItem = idToMarketDetails[current_id];
                items[Index] = currentItem;
                Index++;
            }
            return items;
        }
    }

    function fetchMyNft() public view returns(MarketDetails[] memory) {
        uint totalItemCount = TotalItems.current ();
        uint itemCount = 0;
        uint currentIndex = 0;

        for(uint i=0; i<totalItemCount; i++) {
            if(idToMarketDetails[i+1].owner == msg.sender){
                itemCount = i+1;
            }
        }

        MarketDetails[] memory items = new MarketDetails[](itemCount);

        for(uint i=0; i<totalItemCount; i++) {
            if(idToMarketDetails[i+1].owner == msg.sender) {
                uint currentid = i+1;
                MarketDetails storage currentItem = idToMarketDetails[currentid];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }

    function fetchCreatedNfts() public view returns(MarketDetails[] memory) {
        uint totalItemCount = TotalItems.current ();
        uint itemCount = 0;
        uint currentIndex = 0;

        for(uint i=0; i<totalItemCount; i++) {
            if(idToMarketDetails[i+1].seller == msg.sender){
                itemCount = i+1;
            }
        }

        MarketDetails[] memory items = new MarketDetails[](itemCount);

        for(uint i=0; i<totalItemCount; i++) {
            if(idToMarketDetails[i+1].seller == msg.sender) {
                uint currentid = i+1;
                MarketDetails storage currentItem = idToMarketDetails[currentid];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }
 
}