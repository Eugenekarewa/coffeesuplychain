# All Workings of the Canisters

## CoffeeBean Canister
- ID: `br5f7-7uaaa-aaaaa-qaaca-cai`
- `addBeanDetails(batchId: Text, roastLevel: Text, origin: Text, processingDate: Nat) : async Text`
- `getBeanDetails() : async [BeanDetails]`
- `getBeanDetailsByBatchId(batchId: Text) : async ?BeanDetails`
- `linkBeanToFarm(batchId: Text, farmId: Text) : async Text`

## CoffeeFarm Canister
- ID: `bw4dl-smaaa-aaaaa-qaacq-cai`
- `addBatch(id: Text, farmLocation: Text, certifications: [Text], timestamp: Nat, status: Text) : async Text`
- `updateStatus(id: Text, newStatus: Text) : async Text`
- `getBatches() : async [CoffeeBatch]`
- `addBatchWithBeanDetails(coffeeBeanCanisterId: Principal, id: Text, farmLocation: Text, certifications: [Text], timestamp: Nat, status: Text, roastLevel: Text, origin: Text) : async Text`
- `getCompleteBatchInfo(coffeeBeanCanisterId: Principal, batchId: Text) : async Text`
- `linkBeanDetails(farmId: Text, beanDetails: { roastLevel: Text; origin: Text }) : async Text`
- `sendBatchToRoaster(roastersCanisterId: Principal, batchId: Text, roasterId: Text) : async Text`
- `verifyBatch(batchId: Text, farmId: Text) : async Text`

## AuctionService Canister
- ID: `avqkn-guaaa-aaaaa-qaaea-cai`
- `createAuction(productId: Text, productName: Text, startingBid: Nat, endTime: Nat, batchId: Text) : async Text`
- `closeAuction(auctionId: Text) : async Text`

## AuctionTracking Canister
- ID: `b77ix-eeaaa-aaaaa-qaada-cai`
- `closeAuction(auctionId: Text) : async Text`

## Retailer Canister
- ID: `a3shf-5eaaa-aaaaa-qaafa-cai`
- `verifyProduct(batchId: Text) : async {#ok; #err : Text}`
- `addProduct(productId: Text, productName: Text, batchId: Text, price: Nat, quantity: Nat) : async Text`

## Roasters Canister
- ID: `ajuq4-ruaaa-aaaaa-qaaga-cai`
- `addRoastingBatch(batchId: Text, roasterName: Text, roastDate: Nat, roastLevel: Text, quantity: Nat) : async Text`
- `getRoastingBatches() : async [RoastingBatch]`
- `addRoastingBatchAndUpdateRetailer(batchId: Text, roasterName: Text, roastDate: Nat, roastLevel: Text, quantity: Nat, productName: Text, price: Nat, farmId: Text) : async Text`
- `receiveBatch(batch: CoffeeFarm.CoffeeBatch, roasterId: Text) : async Text`

## SmartPayment Canister
- ID: `aovwi-4maaa-aaaaa-qaagq-cai`
- `initiatePayment(transactionId: Text, sender: Text, recipient: Text, amount: Nat, timestamp: Nat) : async Text`
- `updatePaymentStatus(transactionId: Text, newStatus: Text) : async Text`
- `getTransactions() : async [PaymentTransaction]`
- `verifyAuctionPayment(auctionId: Text) : async Text`

## Canister Interactions
- **CoffeeBean and CoffeeFarm**: The `CoffeeBean` canister links beans to farms, and the `CoffeeFarm` canister can add batches and associated bean details.
- **AuctionService and AuctionTracking**: The `AuctionService` canister calls the `closeAuction` function from the `AuctionTracking` canister to manage auction states.
