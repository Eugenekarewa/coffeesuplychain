import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Array "mo:base/Array";
import Roasters "canister:Roasters";
import AuctionService "canister:AuctionService";

actor Retailer {
  // Define retailer stock
  type Stock = {
    productId: Text;
    productName: Text;
    batchId: Text;
    price: Nat;
    quantity: Nat;
  };

  // Storage for retailer stock
  stable var retailerStock: [Stock] = [];

  // Add product to retailer stock
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

  // Retrieve retailer stock
  public query func getRetailerStock() : async [Stock] {
    retailerStock
  };

  // Add product to retailer stock with roasting batch verification
  public func addProductWithVerification(
    productId: Text,
    productName: Text,
    batchId: Text,
    price: Nat,
    quantity: Nat
  ) : async Text {
    let roastingBatches = await Roasters.getRoastingBatches();
    let batchExists = Array.find<Roasters.RoastingBatch>(roastingBatches, func(b) { b.batchId == batchId });
    
    switch (batchExists) {
      case (null) { "Error: Roasting batch not found" };
      case (?batch) {
        let product = {
          productId;
          productName;
          batchId;
          price;
          quantity;
        };
        retailerStock := Array.append([product], retailerStock);
        "Product added successfully: " # productName # " (Verified batch: " # batchId # ")"
      };
    };
  };

  // Verify product for auction
  public func verifyProduct(batchId: Text) : async {#ok; #err : Text} {
    // This function is now called by AuctionService
    let product = Array.find<Stock>(retailerStock, func(s) { s.batchId == batchId });
    switch (product) {
      case (null) { #err("Product not found") };
      case (?_) { #ok };
    };
  };

  // Update inventory after auction
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

  // Get product by ID
  public query func getProduct(productId: Text) : async ?Stock {
    Array.find(retailerStock, func (s: Stock) : Bool { s.productId == productId })
  };

  // Update product quantity
  public func updateProductQuantity(productId: Text, newQuantity: Nat) : async Text {
    retailerStock := Array.map(retailerStock, func (s: Stock) : Stock {
      if (s.productId == productId) {
        {s with quantity = newQuantity}
      } else {
        s
      }
    });
    "Product quantity updated: " # productId
  };

  // New function to create an auction for a product
public func createAuctionForProduct(productId: Text, startingBid: Nat, endTime: Nat) : async Text {
    let product = Array.find<Stock>(retailerStock, func(s) { s.productId == productId });
    switch (product) {
      case (null) { "Product not found" };
      case (?p) {
        // Call AuctionService to create an auction
        return await AuctionService.createAuction(productId, p.productName, startingBid, endTime, p.batchId);
      };
    };

  };
}
