import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Array "mo:base/Array";
import CoffeeFarm "canister:CoffeeFarm";
import Retailer "canister:Retailer";

actor Roasters {
  type RoastingBatch = {
    batchId: Text;
    roasterName: Text;
    roastDate: Nat;
    roastLevel: Text;
    quantity: Nat;
  };

  stable var roastingBatches: [RoastingBatch] = [];

  public func addRoastingBatchAndUpdateRetailer(
    batchId: Text,
    roasterName: Text,
    roastDate: Nat,
    roastLevel: Text,
    quantity: Nat,
    productName: Text,
    price: Nat,
    farmId: Text
  ) : async Text {
    let farmVerification = await CoffeeFarm.verifyBatch(batchId, farmId);
    if (farmVerification == "Verified") {
      let batch = {
        batchId;
        roasterName;
        roastDate;
        roastLevel;
        quantity;
      };
      roastingBatches := Array.append([batch], roastingBatches);
      let retailerResult = await Retailer.addProduct(batchId, productName, batchId, price, quantity);
      "Roasting batch added successfully: " # batchId # " and " # retailerResult
    } else {
      "Failed to verify batch with farm"
    };
  };

  public query func getRoastingBatches() : async [RoastingBatch] {
    roastingBatches
  };

  public func receiveBatch(batch: CoffeeFarm.CoffeeBatch, _roasterId: Text) : async Text {
    "Batch received from farm: " # batch.id
  };
}
