import Result "mo:base/Result";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Buffer "mo:base/Buffer";
import Option "mo:base/Option";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Types "types";

actor DAO {
        type Result<A, B> = Result.Result<A, B>;
        type Member = Types.Member;
        type ProposalContent = Types.ProposalContent;
        type ProposalId = Types.ProposalId;
        type Proposal = Types.Proposal;
        type Vote = Types.Vote;
        type HttpRequest = Types.HttpRequest;
        type HttpResponse = Types.HttpResponse;
        type Role = Types.Role;
        type ProposalStatus = Types.ProposalStatus;


        // The principal of the Webpage canister associated with this DAO canister (needs to be updated with the ID of your Webpage canister)
        stable let canisterIdWebpage : Principal = Principal.fromText("aaaaa-aa");
        stable var manifesto = "EduConnect is an innovative platform that connects underpriviledged students with qualified educators, mentors, sponsors and resources to help them achieve their academic goals.";
        stable let name = "Abdulsalam";
        stable var goals = [];
        var nextProposalId : Nat = 0;
        let members = HashMap.HashMap<Principal, Member>(0, Principal.equal, Principal.hash);
        let proposals = HashMap.HashMap<ProposalId, Proposal>(0, ProposalId.equal, ProposalId.hash);
        let ledger = HashMap.HashMap<Principal, Nat>(0, Principal.equal, Principal.hash);

        // Returns the name of the DAO
        public query func getName() : async Text {
                return name;
        };

        // Returns the manifesto of the DAO
        public query func getManifesto() : async Text {
                return manifesto;
        };

        // Returns the goals of the DAO
        public query func getGoals() : async [Text] {
                return Buffer.toArray(goals);
        };

        // register a new mentor
        // Returns an error if the mentor already exists
        public  func registerMentor() : async Result<(), Text> {
                let mentorPrincipal = Principal.fromText("nkqop-siaaa-aaaaj-qa3qq-cai");
                switch(members.get(caller)){
                        case(null){
                                let mentor : Member = { name = "Motoko_bootcamp"; role = Role.Mentor};
                                members.put(mentorPrincipal, mentor);
                                ledger.put(mentorPrincipal, 10000);
                                return #ok();

                        };
                        case(?oldMentor){
                                return #err("Already a mentor");
                        };
                };
        };

        // Register a new member in the DAO with the given name and principal of the caller
        // Airdrop 10 MBC tokens to the new member
        // New members are always Student
        // Returns an error if the member already exists
        public shared ({ caller }) func registerMember(member : Member) : async Result<(), Text> {
                switch (members.get(caller)){
                        case(null){
                                let student = {name: member.name; role: Role.Student};
                                members.put(caller, student);
                                ledger.put(caller, 10);
                                return #ok();

                        };
                        case(?oldMember){
                                return #err("Already a member");
                        };
                };
        };

        // Get the member with the given principal
        // Returns an error if the member does not exist
        public query func getMember(p : Principal) : async Result<Member, Text> {
                switch(members.get(caller)){
                        case(null){
                                return #err("Already a member");

                        };
                        case(member){
                                return #ok(member);
                        };
                };
        };

        // Graduate the student with the given principal
        // Returns an error if the student does not exist or is not a student
        // Returns an error if the caller is not a mentor
        public shared ({ caller }) func graduate(student : Principal) : async Result<(), Text> {
                switch(members.get(caller)){
                        case(null){
                                return #err("Student with pricipal :" #Principal.toText(student) # " not found!");

                        };
                        case(?oldStudent){
                                 if(oldStudent.role != Role.Student){
                                        return #err("Member with pricipal :" #Principal.toText(student) # "is not a student!");
                                };
                                let isMentor = members.get(caller);
                                if(isMentor.role != Role.Mentor){
                                        return #err("Not Mentor, Cant graduate student!");
                                };
                                let newStudent = {name: member.name; role: Role.Graduate};
                                members.put(caller, newStudent);
                                return #ok();
                        }
                }
        };

        // Create a new proposal and returns its id
        // Returns an error if the caller is not a mentor or doesn't own at least 1 MBC token
        public shared ({ caller }) func createProposal(content : ProposalContent) : async Result<ProposalId, Text> {
               switch(members.get(caller)){
                        case(null){
                                return #err("Caller is not a Member, Cannot create proposal!");

                        };
                        case(?member){
                               if(isMentor.role != Role.Mentor){
                                        return #err("Not Mentor, Cant create proposal!");
                                };
                                let balance = Options.get(ledger.get(caller) 0);
                                if(balance < 0){
                                                return #err("Not enough  token to create proposal!");
                                };
                                // Create the proposal and burn the token
                                let proposal = {
                                        id = nextProposalId;
                                        content;
                                        creator: caller;
                                        createdTime = Time.now();
                                        executed = null;
                                        votes =[];
                                        vpteScore = 0;
                                        status = ProposalStatus.Open;
                                }
                                proposals.put(nextProposalId, proposal);
                                nextProposalId += 1;
                                ledger.put(caller, balance - 1);
                                return #ok(nextProposalId - 1)

                        };
                };
        };

        // Get the proposal with the given id
        // Returns an error if the proposal does not exist
        public query func getProposal(id : ProposalId) : async Result<Proposal, Text> {
               switch(proposals.get(id)){
                        case(null){
                                return #err("Proposal with" #id # "not found!");
                        };
                        case(?proposal){
                              return #ok(proposal);
                        };
                };
        };

        // Returns all the proposals
        public query func getAllProposal() : async [Proposal] {
                return Iter.toArray(proposals.vals());
        };

        // Vote for the given proposal
        // Returns an error if the proposal does not exist or the member is not allowed to vote

        func _checkUserVote(proposal : Proposal, member : Principal) : async Bool {
                return Array.find<Vote>(
                        proposal.votes,
                        func(vote : Vote){
                                return vote.member == member;
                        }
                )!= null;
        };
        func _getVotingPower(role: String, balance: Nat) : Nat{
                switch(role) {
                        case(Role.Mentor) { 
                                balance * 5;
                         };
                        case(Role.Graduate) {
                                balance;
                         };
                        case(Role.Student) { 0};
                };

        };
        func _getProposalStatus(newVoteScore: Nat) : Text {
                if (newVoteScore >= 100) {
                        return ProposalStatus.Accepted;
                } else if (newVoteScore <= -100) {
                        return ProposalStatus.Rejected;
                } else {
                        return ProposalStatus.Open;
                }
        };
        func _getScore(currentScore : Int, yesorNo : Bool, votingPower: Nat) : Int{
                if(yesOrNo) {
                        return currentScore + votingPower;
                }else {
                        return currentScore - votingPower;
                };
        };
        func _executeProposal(content : ProposalContent){
                switch((content)) {
                        case(#ChangeManifesto(newManifesto)) { 
                                manifesto := newManifesto
                         };
                        case(#AddMentor(principal)) { 
                                switch(members.get(principal)){
                                        case(?member){
                                                if(member.role == Role.Graduate){
                                                        let newMentor = {
                                                                name: member.name;
                                                                role: Role.Mentor;
                                                        };
                                                        member.put(principal, newMentor)
                                                };
                                        };
                                        case(_){}
                                };
                        };
                        case(_) { };
                };
        };


        public shared ({ caller }) func voteProposal(proposalId : ProposalId, yesOrNo : Bool) : async Result<(), Text> {
                switch(members.get(caller)){
                        case(null){
                                return #err("Caller not a member can't vote for proposal!");
                        };
                        case(?member){
                                if(member.role != Role.Mentor or member.role != Role.Graduate){
                                        return #err("Caller not a mentor or gradute,  can't vote for proposal!");
                                };
                                switch(proposals.get(proposalId)){
                                        case(null){
                                                return #err("Proposal does not exist!");
                                        };
                                        case(?proposal){
                                                if(proposal.status != ProposalStatus.Open){
                                                        return #err("The proposal is not open for voting!");
                                                };
                                                if(_checkUserVote(proposal, caller)){
                                                        return #err("Caller already  voted on this proposal!");
                                                };
                                                let balance = Options.get(ledger.get(caller), 0);
                                                let votingPower = _getVotingPower(member.role);
                                                var newExecuted : ?Time.Time = null;
                                                let newVotes = Buffer.fromArray<Vote>(proposals.votes);
                                                let newVoteScore = proposal.voteScore + votingPower;
                                                let newProposalStatus = _getProposalStatus(newVoteScore);
                                                 if (newProposalStatus == ProposalStatus.Accepted) {
                                                        _executeProposal(proposal.content);
                                                        newExecuted := ?Time.now();
                                                };
                                                let newProposal = {
                                                        id: proposal.id;
                                                        content: proposal.content;
                                                        creator: proposal.creator;
                                                        created: proposal.created;
                                                        executed: newExecuted;
                                                        votes = Buffer.toArray(newVotes);
                                                        voteScore = newVoteScore;
                                                        status: newProposalStatus;
                                                };

                                                proposals.put(proposalId, newProposal);
                                                return #ok();
                                        };

                                }
                        }
                }
        };

        // Returns the Principal ID of the Webpage canister associated with this DAO canister
        public query func getIdWebpage() : async Principal {
                return canisterIdWebpage;
        };

};