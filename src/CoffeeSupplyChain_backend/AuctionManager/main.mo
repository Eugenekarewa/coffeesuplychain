import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Array "mo:base/Array";
import Retailer "canister:Retailer";
import AuctionService "canister:AuctionService";

actor AuctionManager {
  public func createAuctionForProduct(
    productId: Text,
    startingBid: Nat,
    endTime: Nat
  ) : async Text {
    let product = await Retailer.getProduct(productId);
    switch (product) {
      case (null) { "Product not found" };
      case (?p) {
        return await AuctionService.createAuction(productId, p.productName, startingBid, endTime, p.batchId);
      };
    };
  };
}