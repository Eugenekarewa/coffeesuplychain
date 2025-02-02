import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Array "mo:base/Array";
import AuctionTrackingInterface "canister:AuctionTrackingInterface";
import RetailerInterface "canister:RetailerInterface";

actor AuctionService {
  type AuctionDetails = {
    auctionId: Text;
    itemName: Text;
    startingBid: Nat;
    highestBid: Nat;
    highestBidder: Text;
    endTime: Nat;
    status: Text;
    batchId: Text;
  };

  stable var auctions: [AuctionDetails] = [];

  public func createAuction(productId: Text, productName: Text, startingBid: Nat, endTime: Nat, batchId: Text) : async Text {
    let auctionId = Text.concat(productId, Nat.toText(auctions.size()));
    let newAuction: AuctionDetails = {
      auctionId = auctionId;
      itemName = productName;
      startingBid = startingBid;
      highestBid = startingBid;
      highestBidder = "";
      endTime = endTime;
      status = "Open";
      batchId = batchId;
    };
    auctions := Array.append(auctions, [newAuction]);
    return auctionId;
  };

  public func closeAuction(auctionId: Text) : async Text {
    let result = await AuctionTrackingInterface.closeAuction(auctionId);
    return result;
  };
}