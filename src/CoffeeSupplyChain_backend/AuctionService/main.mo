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

  public func closeAuction(auctionId: Text) : async Text {
    let result = await AuctionTrackingInterface.closeAuction(auctionId);
    return result;
  };
}
