import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Result "mo:base/Result";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Types "types";
actor {

    let name = "Motoko Bootcamp";
    var manifesto = "Empower the next generation of builders and make the DAO-revolution a reality";
    let goals = Buffer.Buffer<Text>(0);
    //   chapter two
    type Member = Types.Member;
    type Result<Ok, Err> = Types.Result<Ok, Err>;
    type HashMap<K, V> = Types.HashMap<K, V>;
   let members = HashMap.HashMap<Principal, Member>(0, Principal.equal, Principal.hash);
    //   chapter three
    let token = "Motoko Bootcamp Token";
    let tSymbol = "MBT";
   let ledger = HashMap.HashMap<Principal, Nat>(0, Principal.equal, Principal.hash);

    public shared query func getName() : async Text {
        return name;
    };

    public shared query func getManifesto() : async Text {
        return manifesto;
    };

   public func setManifesto(newManifesto : Text) : async () {
    manifesto := newManifesto;
        return;
    };

    public func addGoal(newGoal : Text) : async () {
        goals.add(newGoal);
        return;
    };

    public shared query func getGoals() : async [Text] {
        Buffer.toArray(goals);
    };


    public shared ({ caller }) func addMember(member : Member) : async Result<(), Text> {
        switch (members.get(caller)) {
            case (null) {
                members.put(caller, member);
                return #ok();
            };
            case (?member) {
                return #err("Member already exists");
            };
        };
    };

    public shared ({ caller }) func updateMember(newMember : Member) : async Result<(), Text> {
        switch (members.get(caller)) {
            case (null) {
                return #err("Member does not exist");
            };
            case (?member) {
                members.put(caller, newMember);
                return #ok();
            };
        };
    };

    public shared ({ caller }) func removeMember() : async Result<(), Text> {
        switch (members.get(caller)) {
            case (null) {
                return #err("Member does not exist");
            };
            case (?member) {
                members.delete(caller);
                return #ok();
            };
        };
    };

    public query func getMember(p : Principal) : async Result<Member, Text> {
        switch (members.get(p)) {
            case (null) {
                return #err("Member does not exist");
            };
            case (?member) {
                return #ok(member);
            };
        };
    };

    public query func getAllMembers() : async [Member] {
        return Iter.toArray(members.vals());
    };

    public query func numberOfMembers() : async Nat {
        return members.size();
    };

    public query func tokenName() : async Text {
        return token;
    };

    public query func tokenSymbol() : async Text {
        return tSymbol;
    };

    public func mint(owner : Principal, amount : Nat) : async Result<(), Text> {
        let ownerBalance = Option.get(ledger.get(owner), 0);
        ledger.put(owner, ownerBalance + amount);
        return #ok();
    };

    public func burn(owner : Principal, amount : Nat) : async Result<(), Text> {
       let ownerBalance = Option.get(ledger.get(owner), 0);
       if (ownerBalance < amount) {
           return #err("Insufficient balance!");
       };
        ledger.put(owner, ownerBalance - amount);
        return #ok();
    };

    public shared ({ caller }) func transfer(from : Principal, to : Principal, amount : Nat) : async Result<(), Text> {
         if (from == to) {
            return #err("Cannot transfer to self");
        };
       let ownerBalance = Option.get(ledger.get(from), 0);
       let receiverBalance = Option.get(ledger.get(to), 0);
        if (ownerBalance < amount) {
           return #err("Insufficient balance for this transfer!");
       };
        ledger.put(from, ownerBalance - amount);
        ledger.put(to, receiverBalance + amount);
        return #ok();
    };

    public query func balanceOf(account : Principal) : async Nat {
        let ownerBalance = Option.get(ledger.get(account), 0);
        return ownerBalance
    };

    public query func totalSupply() : async Nat {
        var totalBalance = 0;
        for ( balance in ledger.vals()) {
            totalBalance := totalBalance + balance;
            // totalBalance += balance;
        };
        // Alternative way to calculate total token supply:
        // let totalBalance = Iter.foldLeft(ledger.vals(), 0, (acc, balance) => acc + balance);
        return totalBalance;
    };
};

// dfx identity get-principal
// dfx identity list
// dfx new identity test --storage-mode=plaintext