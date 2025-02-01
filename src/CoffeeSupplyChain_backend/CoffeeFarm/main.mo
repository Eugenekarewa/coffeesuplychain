import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import CoffeeBean "canister:CoffeeBean";
import Roasters "canister:Roasters";

actor CoffeeFarm {
  // Define a coffee batch
  type CoffeeBatch = {
    id: Text;
    farmLocation: Text;
    certifications: [Text];
    timestamp: Nat;
    status: Text;
  };

  // Storage for coffee batches
  stable var coffeeBatches: [CoffeeBatch] = [];

  // Add a new coffee batch
  public func addBatch(
    id: Text,
    farmLocation: Text,
    certifications: [Text],
    timestamp: Nat,
    status: Text
  ) : async Text {
    let batch = {
      id;
      farmLocation;
      certifications;
      timestamp;
      status;
    };
    coffeeBatches := Array.append([batch], coffeeBatches);
    "Batch added successfully: " # id
  };

  // Update coffee batch status
  public func updateStatus(id: Text, newStatus: Text) : async Text {
    if (Text.size(newStatus) == 0) {
        return "Invalid status: Status cannot be empty.";
    };
    coffeeBatches := Array.map<CoffeeBatch, CoffeeBatch>(
      coffeeBatches,
      func (batch) {
        if (batch.id == id) {
          { batch with status = newStatus }
        } else {
          batch
        }
      }
    );
    "Status updated for batch: " # id
  };

  // Fetch coffee batches
  public query func getBatches() : async [CoffeeBatch] {
    coffeeBatches
  };

  // Add a new batch with bean details (inter-canister call)
  public func addBatchWithBeanDetails(
    id: Text,
    farmLocation: Text,
    certifications: [Text],
    timestamp: Nat,
    status: Text,
    roastLevel: Text,
    origin: Text
  ) : async Text {
    let batchResult = await addBatch(id, farmLocation, certifications, timestamp, status);
    let beanResult = await CoffeeBean.addBeanDetails(id, roastLevel, origin, timestamp);
    batchResult # " and " # beanResult
  };

  // Get complete information for a batch (inter-canister call)
  public func getCompleteBatchInfo(batchId: Text) : async Text {
    let batchInfo = Array.find<CoffeeBatch>(coffeeBatches, func(b) { b.id == batchId });
    switch (batchInfo) {
      case (null) { "Batch not found" };
      case (?batch) {
        let beanInfo = await CoffeeBean.getBeanDetailsByBatchId(batchId);
        switch (beanInfo) {
          case (null) { "Batch found, but no bean details available" };
          case (?bean) {
            "Batch ID: " # batch.id #
            "\nFarm Location: " # batch.farmLocation #
            "\nStatus: " # batch.status #
            "\nRoast Level: " # bean.roastLevel #
            "\nOrigin: " # bean.origin
          };
        };
      };
    };
  };

  // New function to link bean details
  public func linkBeanDetails(farmId: Text, beanDetails: CoffeeBean.BeanDetails) : async Text {
    // Implementation to link bean details to a farm
    "Bean details linked to farm: " # farmId
  };

  // New function to send batch to roaster
  public func sendBatchToRoaster(batchId: Text, roasterId: Text) : async Text {
    let batch = Array.find<CoffeeBatch>(coffeeBatches, func(b) { b.id == batchId });
    switch (batch) {
      case (null) { "Batch not found" };
      case (?b) {
        let roastingResult = await Roasters.receiveBatch(b, roasterId);
        "Batch sent to roaster: " # roastingResult
      };
    };
  };

  // New function to verify batch
  public func verifyBatch(batchId: Text, farmId: Text) : async Text {
    let batch = Array.find<CoffeeBatch>(coffeeBatches, func(b) { b.id == batchId });
    switch (batch) {
      case (null) { "Batch not found" };
      case (?b) {
        if (b.farmLocation == farmId) {
          "Verified"
        } else {
          "Not verified"
        };
      };
    };
  };
}