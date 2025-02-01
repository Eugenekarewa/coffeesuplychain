import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Array "mo:base/Array";
import CoffeeFarm "canister:CoffeeFarm";

actor CoffeeBean {
  // Define coffee bean properties
  type BeanDetails = {
    batchId: Text;
    roastLevel: Text;
    origin: Text;
    processingDate: Nat;
  };

  // Storage for bean details
  stable var beanDetails: [BeanDetails] = [];

  // Add bean details
  public func addBeanDetails(
    batchId: Text,
    roastLevel: Text,
    origin: Text,
    processingDate: Nat
  ) : async Text {
    let bean = {
      batchId;
      roastLevel;
      origin;
      processingDate;
    };
    beanDetails := Array.append([bean], beanDetails);
    "Bean details added successfully for batch: " # batchId
  };

  // Retrieve bean details
  public query func getBeanDetails() : async [BeanDetails] {
    beanDetails
  };

  // Retrieve bean details for a specific batch
  public query func getBeanDetailsByBatchId(batchId: Text) : async ?BeanDetails {
    Array.find<BeanDetails>(beanDetails, func(b) { b.batchId == batchId })
  };

  // New function to link bean details with a farm
  public func linkBeanToFarm(batchId: Text, farmId: Text) : async Text {
    let beanDetail = Array.find<BeanDetails>(beanDetails, func(b) { b.batchId == batchId });
    switch (beanDetail) {
      case (null) { "Bean details not found" };
      case (?bean) {
        let linkResult = await CoffeeFarm.linkBeanDetails(farmId, bean);
        "Bean details linked to farm: " # farmId
      };
    };
  };
}