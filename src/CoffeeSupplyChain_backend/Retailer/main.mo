import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Array "mo:base/Array";

actor Retailer {
  type Stock = {
    productId: Text;
    productName: Text;
    batchId: Text;
    price: Nat;
    quantity: Nat;
  };

  stable var stock: [Stock] = [];

  public func verifyProduct(batchId: Text) : async { #ok : (); #err : Text } {
    let product = Array.find<Stock>(stock, func(s) { s.batchId == batchId });
    switch (product) {
      case (null) { #err("Product not found") };
      case (?_) { #ok() };
    };
  };

  public func addProduct(
    productId: Text,
    productName: Text,
    batchId: Text,
    price: Nat,
    quantity: Nat
  ) : async Text {
    let newProduct : Stock = {
      productId;
      productName;
      batchId;
      price;
      quantity;
    };
    stock := Array.append([newProduct], stock);
    "Product added successfully."
  };
}