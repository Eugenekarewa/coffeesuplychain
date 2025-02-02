import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Array "mo:base/Array";
import ProductService "canister:ProductService";
import AuctionManager "canister:AuctionManager";
import RetailerInterface "canister:RetailerInterface";

actor Retailer {
  type Stock = {
    productId: Text;
    productName: Text;
    batchId: Text;
    price: Nat;
    quantity: Nat;
  };

  public func verifyProduct(batchId: Text) : async {#ok; #err : Text} {
    let product = await ProductService.getProductByBatchId(batchId);
    switch (product) {
      case (null) { #err("Product not found") };
      case (?_) { #ok };
    };
  };
}
