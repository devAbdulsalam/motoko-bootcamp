// import Dao "canister:dao";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Types "types";


actor Webpage {

    type Result<A, B> = Result.Result<A, B>;
    type HttpRequest = Types.HttpRequest;
    type HttpResponse = Types.HttpResponse;

    // The manifesto stored in the webpage canister should always be the same as the one stored in the DAO canister
    stable var manifesto : Text = "Let's graduate!";

    
    stable let daoCanister: Principal = Principal.fromText("b77ix-eeaaa-aaaaa-qaada-cai");


    func _getWebpage() : Text {
        var webpage = "<style>" #
        "body { text-align: center; font-family: Arial, sans-serif; background-color: #f0f8ff; color: #333; }" #
        "h1 { font-size: 3em; margin-bottom: 10px; }" #
        "hr { margin-top: 20px; margin-bottom: 20px; }" #
        "em { font-style: italic; display: block; margin-bottom: 20px; }" #
        "ul { list-style-type: none; padding: 0; }" #
        "li { margin: 10px 0; }" #
        "li:before { content: '👉 '; }" #
        "svg { max-width: 150px; height: auto; display: block; margin: 20px auto; }" #
        "h2 { text-decoration: underline; }" #
        "</style>";

        webpage := webpage # "<em>" # manifesto # "</em>";
        return webpage;
    };

    // The webpage displays the manifesto
    public  shared func http_request(request : HttpRequest) : async HttpResponse {
        return ({
            status_code = 200;
            headers = [("Content-Type", "text/html; charset=UTF-8")];
            body = Text.encodeUtf8(_getWebpage());
            // body = Text.encodeUtf8(manifesto);
            streaming_strategy = null;
        });
    };
    

    // This function should only be callable by the DAO canister (no one else should be able to change the manifesto)
    // public shared ({ caller }) func setManifesto(newManifesto : Text) : async Result<(), Text> {
    //     let memberResult = await Dao.getMember(caller);
    //     switch (memberResult) {
    //         case (#ok(_)) {
    //             manifesto := newManifesto;
    //             return #ok();
    //         };
    //         case (#err(msg)) {
    //             return #err("Not authorized to set manifesto: " # msg);
    //         };
    //     };
    // };
    public shared ({ caller }) func setManifesto(newManifesto: Text): async Result<(), Text> {
        if (caller == daoCanister) {
            manifesto := newManifesto;
            return #ok(());
        } else {
            return #err("Unauthorized");
        }
    };
};
