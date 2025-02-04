import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Array "mo:base/Array";
import Principal "mo:base/Principal";

actor CoffeeFarm {
  type CoffeeBatch = {
    id: Text;
    farmLocation: Text;
    certifications: [Text];
    timestamp: Nat;
    status: Text;
  };

  stable var coffeeBatches: [CoffeeBatch] = [];

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

  public query func getBatches() : async [CoffeeBatch] {
    coffeeBatches
  };

  public func addBatchWithBeanDetails(
    coffeeBeanCanisterId: Principal,
    id: Text,
    farmLocation: Text,
    certifications: [Text],
    timestamp: Nat,
    status: Text,
    roastLevel: Text,
    origin: Text
  ) : async Text {
    let batchResult = await addBatch(id, farmLocation, certifications, timestamp, status);
    let coffeeBeanActor = actor(Principal.toText(coffeeBeanCanisterId)) : actor {
      addBeanDetails : (Text, Text, Text, Nat) -> async Text;
    };
    let beanResult = await coffeeBeanActor.addBeanDetails(id, roastLevel, origin, timestamp);
    batchResult # " and " # beanResult
  };

  public func getCompleteBatchInfo(coffeeBeanCanisterId: Principal, batchId: Text) : async Text {
    let batchInfo = Array.find<CoffeeBatch>(coffeeBatches, func(b) { b.id == batchId });
    switch (batchInfo) {
      case (null) { "Batch not found" };
      case (?batch) {
        let coffeeBeanActor = actor(Principal.toText(coffeeBeanCanisterId)) : actor {
          getBeanDetailsByBatchId : (Text) -> async ?{ roastLevel: Text; origin: Text };
        };
        let beanInfo = await coffeeBeanActor.getBeanDetailsByBatchId(batchId);
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

  public func linkBeanDetails(farmId: Text, _beanDetails: { roastLevel: Text; origin: Text }) : async Text {
    "Bean details linked to farm: " # farmId
  };

  public func sendBatchToRoaster(roastersCanisterId: Principal, batchId: Text, roasterId: Text) : async Text {
    let batch = Array.find<CoffeeBatch>(coffeeBatches, func(b) { b.id == batchId });
    switch (batch) {
      case (null) { "Batch not found" };
      case (?b) {
        let roastersActor = actor(Principal.toText(roastersCanisterId)) : actor {
          receiveBatch : (CoffeeBatch, Text) -> async Text;
        };
        let roastingResult = await roastersActor.receiveBatch(b, roasterId);
        "Batch sent to roaster: " # roastingResult
      };
    };
  };

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
