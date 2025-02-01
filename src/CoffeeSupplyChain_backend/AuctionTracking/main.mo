import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import AuctionService "canister:AuctionService";
import Time "mo:base/Time";

actor AuctionTracking {
  // Define auction details
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

  // Storage for auctions
  stable var auctions: [AuctionDetails] = [];

  // Create a new auction
  public func createAuction(
    auctionId: Text,
    itemName: Text,
    startingBid: Nat,
    endTime: Nat,
    batchId: Text
  ) : async Text {
    // Verify the product with Retailer canister
    let verificationResult = await AuctionService.createAuction(auctionId, itemName, startingBid, endTime, batchId);
    
    switch (verificationResult) {
      case (#ok) {
        let auction = {
          auctionId;
          itemName;
          startingBid;
          highestBid = startingBid;
          highestBidder = "";
          endTime;
          status = "Active";
          batchId;
        };
        auctions := Array.append([auction], auctions);
        "Auction created successfully: " # auctionId
      };
      case (#err(message)) {
        "Failed to create auction: " # message
      };
    };
  };

  // Place a bid
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

  // Close auction
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
        // Update Retailer inventory
        let updateResult = await Retailer.updateInventory(auction.batchId, auction.highestBidder, 1);
        switch (updateResult) {
          case (#ok) { "Auction closed successfully: " # auctionId # ". Inventory updated." };
          case (#err(message)) { "Auction closed, but failed to update inventory: " # message };
        };
      };
    };
  };

  // Retrieve all auctions
  public query func getAuctions() : async [AuctionDetails] {
    auctions
  };
}
