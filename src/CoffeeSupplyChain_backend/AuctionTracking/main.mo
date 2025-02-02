import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import AuctionService "canister:AuctionService";
import Time "mo:base/Time";

actor AuctionTracking {
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

  public func createAuction(
    auctionId: Text,
    itemName: Text,
    startingBid: Nat,
    endTime: Nat,
    batchId: Text
  ) : async Text {
    let verificationResult = await AuctionService.createAuction(auctionId, itemName, startingBid, endTime, batchId);
    verificationResult
  };

  public func placeBid(auctionId: Text, bidder: Text, bidAmount: Nat) : async Text {
    let auction = Array.find<AuctionDetails>(auctions, func(a) { a.auctionId == auctionId });
    switch (auction) {
      case (null) { "Auction not found" };
      case (?a) {
        if (a.status == "Active" and bidAmount > a.highestBid) {
          let paymentResult = await AuctionService.closeAuction(auctionId);
          if (Text.contains(paymentResult, "successfully")) {
            auctions := Array.map<AuctionDetails, AuctionDetails>(
              auctions,
              func (auction) {
                if (auction.auctionId == auctionId) {
                  { auction with highestBid = bidAmount; highestBidder = bidder }
                } else {
                  auction
                }
              }
            );
            "Bid placed successfully for auction: " # auctionId
          } else {
            "Bid failed due to payment issue: " # paymentResult
          }
        } else {
          "Invalid bid"
        }
      };
    };
  };

  public func closeAuction(auctionId: Text) : async Text {
    var closedAuction: ?AuctionDetails = null;
    auctions := Array.map<AuctionDetails, AuctionDetails>(
      auctions,
      func (auction) {
        if (auction.auctionId == auctionId and auction.status == "Active") {
          closedAuction := ?{ auction with status = "Closed" };
          { auction with status = "Closed" }
        } else {
          auction
        }
      }
    );

    switch (closedAuction) {
      case (null) { "Auction not found or already closed: " # auctionId };
      case (?auction) {
        let updateResult = await Retailer.updateInventory(auction.batchId, auction.highestBidder, 1);
        switch (updateResult) {
          case (#ok) { "Auction closed successfully: " # auctionId # ". Inventory updated." };
          case (#err(message)) { "Auction closed, but failed to update inventory: " # message };
        };
      };
    };
  };

  public query func getAuctions() : async [AuctionDetails] {
    auctions
  };
}