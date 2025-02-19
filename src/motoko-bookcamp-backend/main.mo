import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Result "mo:base/Result";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Types "types";
actor {


  let name = "Motoko Bootcamp";
  var manifesto = "Empower the next generation of builders and make the DAO-revolution a reality";
  let goals = Buffer.Buffer<Text>(0);

//   chapter two
    type Member = Types.Member;
    type Result<Ok, Err> = Types.Result<Ok, Err>;
    type HashMap<K, V> = Types.HashMap<K, V>;

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
  let members = HashMap.HashMap<Principal, Member>(0, Principal.equal, Principal.hash);

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

};