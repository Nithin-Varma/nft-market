const{expect} = require("chai")
const {describe, it } = require("node:test");
describe("NFT_Market", function(){

  it("Deploy the smart contracts, mint nfts, set price and sell the nft.", async () => {
    const Market = await ethers.getContractFactory("NFT_Market")
    const market = await Market.deploy()
    await market.deployed();
    const marketAddress = market.address;

    const NFT = await ethers.getContractFactory("NFT_Create")
    const nft = await NFT.deploy(marketaddress);
    await nft.deployed()
    const nftContractAddress = nft.address;

    let ListingPrice = await market.getlistingPrice();
    ListingPrice = ListingPrice.toString();

    const sellingPrice = ethers.utils.parseUnits("10", "ether");
    await nft.createToken("https://www.google0.com");
    await nft.createToken("https://www.google1.com");

    await market.CreateMarketItem(nftContractAddress, 1, sellingPrice, {value:ListingPrice});
    await market.CreateMarketItem(nftContractAddress, 2, sellingPrice, {value:ListingPrice});

    const[_, buyerAddress] = await ethers.getSigners();
    await market.connect(buyerAddress).createMarketforSale(nftContractAddress, 1, {value:sellingPrice});

    let items = await market.fetchAvailableItems();
    items = await Promise.all(items.map(async i => {
      const tokenURI = await nft.tokenURI(i.tokenId);
      let item={
        price:i.price.toString(),
        tokenId:i.tokenId.toString(),
        seller: i.seller,
        owner: i.owner,
        tokenURI
      }
      return item
    }))

    console.log("items: ",items);


  })


})