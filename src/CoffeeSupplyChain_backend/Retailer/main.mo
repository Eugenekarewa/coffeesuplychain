import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Array "mo:base/Array";
import Roasters "canister:Roasters";
import AuctionManager "canister:AuctionManager";

actor Retailer {
  type Stock = {
    productId: Text;
    productName: Text;
    batchId: Text;
    price: Nat;
    quantity: Nat;
  };

  stable var retailerStock: [Stock] = [];

  public func addProduct(
    productId: Text,
    productName: Text,
    batchId: Text,
    price: Nat,
    quantity: Nat
  ) : async Text {
    let product = {
      productId;
      productName;
      batchId;
      price;
      quantity;
    };
    retailerStock := Array.append([product], retailerStock);
    "Product added successfully: " # productName
  };

  public query func getRetailerStock() : async [Stock] {
    retailerStock
  };

  public func verifyProduct(batchId: Text) : async {#ok; #err : Text} {
    let product = Array.find<Stock>(retailerStock, func(s) { s.batchId == batchId });
    switch (product) {
      case (null) { #err("Product not found") };
      case (?_) { #ok };
    };
  };

  public func updateInventory(batchId: Text, newOwner: Text, quantity: Nat) : async {#ok; #err : Text} {
    retailerStock := Array.map<Stock, Stock>(
      retailerStock,
      func (stock) {
        if (stock.batchId == batchId) {
          if (stock.quantity >= quantity) {
            { stock with quantity = stock.quantity - quantity }
          } else {
            stock
          }
        } else {
          stock
        }
      }
    );
    #ok
  };

  public query func getProduct(productId: Text) : async ?Stock {
    Array.find(retailerStock, func (s: Stock) : Bool { s.productId == productId })
  };

  public func createAuctionForProduct(productId: Text, startingBid: Nat, endTime: Nat) : async Text {
    return await AuctionManager.createAuctionForProduct(productId, startingBid, endTime);
  };
}