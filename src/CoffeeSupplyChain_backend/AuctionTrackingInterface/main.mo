import Text "mo:base/Text";

actor class AuctionTrackingInterface() = this {
  public func closeAuction(auctionId: Text) : async Text {
    return "Auction closing logic will be implemented in AuctionTracking";
  };
}
