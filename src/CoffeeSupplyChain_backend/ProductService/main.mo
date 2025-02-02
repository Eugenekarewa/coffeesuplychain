import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Array "mo:base/Array";
import ProductServiceInterface "../ProductServiceInterface";

actor class ProductService() : async ProductServiceInterface.ProductServiceInterface {
  type Stock = ProductServiceInterface.Stock;

  stable var retailerStock: [Stock] = [];

  public func addProduct(
    productId: Text,
    productName: Text,
    batchId: Text,
    price: Nat,
    quantity: Nat
  ) : async Text {
    let product = { productId; productName; batchId; price; quantity; };
    retailerStock := Array.append([product], retailerStock);
    return "Product added successfully: " # productName;
  };

  public func getProduct(productId: Text) : async ?Stock {
    Array.find(retailerStock, func (s: Stock) : Bool { s.productId == productId })
  };

  public func getProductByBatchId(batchId: Text) : async ?Stock {
    Array.find(retailerStock, func (s: Stock) : Bool { s.batchId == batchId })
  };
}