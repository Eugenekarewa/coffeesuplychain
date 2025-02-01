import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Array "mo:base/Array";
import Retailer "canister:Retailer";
import CoffeeFarm "canister:CoffeeFarm";

actor Roasters {
  // Define roasting batch
  type RoastingBatch = {
    batchId: Text;
    roasterName: Text;
    roastDate: Nat;
    roastLevel: Text;
    quantity: Nat;
  };

  // Storage for roasting batches
  stable var roastingBatches: [RoastingBatch] = [];

  // Add a roasting batch
  public func addRoastingBatch(
    batchId: Text,
    roasterName: Text,
    roastDate: Nat,
    roastLevel: Text,
    quantity: Nat
  ) : async Text {
    let batch = {
      batchId;
      roasterName;
      roastDate;
      roastLevel;
      quantity;
    };
    roastingBatches := Array.append([batch], roastingBatches);
    "Roasting batch added successfully: " # batchId
  };

  // Retrieve roasting batches
  public query func getRoastingBatches() : async [RoastingBatch] {
    roastingBatches
  };

  // Add a roasting batch and update retailer stock
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
      let batchResult = await addRoastingBatch(batchId, roasterName, roastDate, roastLevel, quantity);
      // Product addition handled elsewhere
      "Product addition is handled by another service."
      batchResult # " and " # retailerResult
    } else {
      "Failed to verify batch with farm"
    };
  };

  // New function to receive batch from farm
  public func receiveBatch(batch: CoffeeFarm.CoffeeBatch, roasterId: Text) : async Text {
    // Implementation to receive and process the batch
    "Batch received from farm: " # batch.id
  };
}
