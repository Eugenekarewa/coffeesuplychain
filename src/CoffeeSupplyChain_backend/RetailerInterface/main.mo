import Text "mo:base/Text";

actor class RetailerInterface() = this {
  public func verifyProduct(_batchId: Text) : async {#ok; #err : Text} {
    return #err("Retailer not yet implemented");
  };
}
