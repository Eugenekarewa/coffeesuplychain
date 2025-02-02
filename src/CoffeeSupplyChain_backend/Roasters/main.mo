import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Array "mo:base/Array";
import Retailer "canister:Retailer";
import CoffeeFarm "canister:CoffeeFarm";
import ProductService "canister:ProductService";

actor Roasters {
  type RoastingBatch = {
    batchId: Text;
    roasterName: Text;
    roastDate: Nat;
    roastLevel: Text;
    quantity: Nat;
  };

  stable var roastingBatches: [RoastingBatch] = [];

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

  public query func getRoastingBatches() : async [RoastingBatch] {
    roastingBatches
  };

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
      let retailerResult = await Retailer.addProduct(batchId, productName, batchId, price, quantity);
      batchResult # " and " # retailerResult
    } else {
      "Failed to verify batch with farm"
    };
  };

  public func receiveBatch(batch: CoffeeFarm.CoffeeBatch, roasterId: Text) : async Text {
    "Batch received from farm: " # batch.id
  };
}