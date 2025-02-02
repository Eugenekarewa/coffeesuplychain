import Text "mo:base/Text";
import Nat "mo:base/Nat";

module {
  public type Stock = {
    productId: Text;
    productName: Text;
    batchId: Text;
    price: Nat;
    quantity: Nat;
  };

  public type ProductServiceInterface = actor {
    addProduct: (Text, Text, Text, Nat, Nat) -> async Text;
    getProduct: (Text) -> async ?Stock;
    getProductByBatchId: (Text) -> async ?Stock;
  };
};