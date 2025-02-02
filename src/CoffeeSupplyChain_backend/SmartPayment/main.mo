import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Array "mo:base/Array";
import AuctionService "canister:AuctionService";

actor SmartPayment {
  type PaymentTransaction = {
    transactionId: Text;
    sender: Text;
    recipient: Text;
    amount: Nat;
    timestamp: Nat;
    status: Text;
  };

  stable var transactions: [PaymentTransaction] = [];

  public func initiatePayment(
    transactionId: Text,
    sender: Text,
    recipient: Text,
    amount: Nat,
    timestamp: Nat
  ) : async Text {
    let transaction = {
      transactionId;
      sender;
      recipient;
      amount;
      timestamp;
      status = "Pending";
    };
    transactions := Array.append([transaction], transactions);
    "Payment initiated successfully: " # transactionId
  };

  public func updatePaymentStatus(transactionId: Text, newStatus: Text) : async Text {
    transactions := Array.map<PaymentTransaction, PaymentTransaction>(
      transactions,
      func (txn: PaymentTransaction) : PaymentTransaction {
        if (txn.transactionId == transactionId) {
          { txn with status = newStatus }
        } else {
          txn
        }
      }
    );
    "Payment status updated for transaction: " # transactionId
  };

  public query func getTransactions() : async [PaymentTransaction] {
    transactions
  };

  public func verifyAuctionPayment(auctionId: Text) : async Text {
    let transaction = Array.find<PaymentTransaction>(transactions, func(t: PaymentTransaction) : Bool { t.transactionId == auctionId });
    switch (transaction) {
      case (null) { "Payment not found for auction" };
      case (?t) {
        if (t.status == "Completed") {
          let auctionResult = await AuctionService.closeAuction(auctionId);
          "Payment verified and auction closed: " # auctionResult
        } else {
          "Payment not completed for auction"
        };
      };
    };
  };
}