import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Array "mo:base/Array";
import CoffeeFarm "canister:CoffeeFarm";

actor CoffeeBean {
  type BeanDetails = {
    batchId: Text;
    roastLevel: Text;
    origin: Text;
    processingDate: Nat;
  };

  stable var beanDetails: [BeanDetails] = [];

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

  public query func getBeanDetails() : async [BeanDetails] {
    beanDetails
  };

  public query func getBeanDetailsByBatchId(batchId: Text) : async ?BeanDetails {
    Array.find<BeanDetails>(beanDetails, func(b) { b.batchId == batchId })
  };

  public func linkBeanToFarm(batchId: Text, farmId: Text) : async Text {
    let beanDetail = Array.find<BeanDetails>(beanDetails, func(b) { b.batchId == batchId });
    switch (beanDetail) {
      case (null) { "Bean details not found" };
      case (?bean) {
        let _linkResult = await CoffeeFarm.linkBeanDetails(farmId, bean);
        "Bean details linked to farm: " # farmId
      };
    };
  };
}
