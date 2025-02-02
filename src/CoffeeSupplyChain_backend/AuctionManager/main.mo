import Text "mo:base/Text";
import Nat "mo:base/Nat";
import ProductServiceInterface "../ProductServiceInterface";
import AuctionService "canister:AuctionService";

actor AuctionManager {
  var productService : ?ProductServiceInterface.ProductServiceInterface = null;

  public func setProductService(ps: ProductServiceInterface.ProductServiceInterface) : async () {
    productService := ?ps;
  };

  public func createAuctionForProduct(
    productId: Text,
    startingBid: Nat,
    endTime: Nat
  ) : async Text {
    switch (productService) {
      case (null) { return "Product service not set"; };
      case (?ps) {
        let product = await ps.getProduct(productId);
        switch (product) {
          case (null) { return "Product not found"; };
          case (?p) {
            return await AuctionService.createAuction(productId, p.productName, startingBid, endTime, p.batchId);
          };
        };
      };
    };
  };
}
