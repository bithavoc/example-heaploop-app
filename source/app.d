import webcaret.application;
import heaploop.looping;
import heaploop.networking.http;
import std.string : format;
import couched;
import std.json;
import std.process : environment;
import std.conv : to;
import std.stdio;

const string IdAppId = "e9f3adee2f9710cc0592e5ed03f28c9c";

void main() {
    loop ^^= {
        string couchedUrl = environment.get("CLAUDANT_URL");
        if(couchedUrl is null) {
            couchedUrl = "http://127.0.0.1:5984";
        }
        writeln("Connecting to " ~ couchedUrl);
        auto client = new CouchedClient(couchedUrl);
        CouchedDatabase tags = client.databases.tags;
        tags.ensure();
        auto app = new Application;
        with(app.router) {
            get("/") ^ (req, res) {
                res.contentType = "text/html";
                res.write(r"
                        <html>
                            <body>
                                <h1>Deeq JSON REST API</h1>
                            </body>
                        </html>" ~ "\r\n");
                res.end;
            };

            get("/tags") ^ (req, res) {
                                
            };

            post("/tokens") ^ (req, res) {
                writeln("POST to Tokens");
                writeln("Request FORM contains %d fields", req.form.length);
                if("code" in req.form) {
                    string code = req.form["code"];
                    writeln("POST Tokens is ", code);
                    //auto client = new HttpClient("http://id.bithavoc.io");
                    auto client = new HttpClient("http://127.0.0.1:4000");
                    string[string] fields;
                    fields["code"] = code;
                    auto content = new FormUrlEncodedContent(fields);
                    auto response = client.post("/apps/" ~ IdAppId ~ "/tokens", content);
                    writeln("TOKENS POST RESPONSE came back from server");
                    ubyte[] responseBuffer;
                    response.read ^= (data) {
                        responseBuffer ~= data.buffer;
                    };
                    string responseString = cast(string)responseBuffer;
                    writeln("CLIENT RESPONSE: " ~ responseString);
                    writeln("Status Code ", response.statusCode);
                    if(response.statusCode == 201) {
                        auto responseDoc = responseString.parseJSON;
                        if(responseDoc != JSONValue.init && responseDoc.type == JSON_TYPE.OBJECT) {
                            auto tokenValue = responseDoc.object["token"];
                            if(tokenValue != JSONValue.init && tokenValue.type == JSON_TYPE.STRING) {
                                string token = tokenValue.str;
                                writeln("Token is ", token);
                                res.statusCode = 201;
                                res.contentType= "application/json";
                                res.write("{\"success\": true, \"token\": \"%s\"}".format(token));
                            } else {
                                res.statusCode = 402;
                                res.contentType= "application/json";
                                res.write("{success: false, message: \"Internal token not valid\"}");
                            }
                        } else {
                            res.statusCode = 402;
                            res.contentType= "application/json";
                            res.write("{success: false, message: \"Internal error\"}");
                        }
                    } else {
                        res.statusCode = 422;
                        res.contentType= "application/json";
                        res.write("{success: false, message: \"Code is not valid\"}");
                    }
                } else {
                    writeln("POST doesn't contain the code");
                    res.statusCode = 422;
                    res.contentType= "application/json";
                    res.write("{success: false, message: \"Token is required\"}");
                }
                writeln("ENDING response");
                res.end;
            };

            // curl -X POST -d "name=business" 0.0.0.0:3000/tags
            post("/tags") ^ (req, res) {
                try {
                string tagName = null;
                if("name" in req.form) {
                    writeln("Name param is present, cool");
                    tagName = req.form["name"];
                } else {
                    writeln("Tag name is required");
                    res.statusCode = 422;
                    res.contentType= "application/json";
                    res.write("{success: false, message: \"Tag name is required\"}");
                    res.end;
                    return;
                }
                writeln("QUERYNG DB FOR NAME" ~ tagName);
                JSONValue existingTag;
                try {
                    existingTag = tags.get(tagName);
                } catch(CouchedException cex) {
                    if(cex.error == CouchedError.NotFound) {
                        writeln("Tag will be created");
                    } else {
                        writeln("Error retrieving tag");
                        throw cex;
                    }
                }
                if(existingTag == JSONValue.init) {
                    // create tag
                    JSONValue tagInfo = parseJSON(q{
                        {
                            "name": "%s"
                        }
                    }.format(tagName));
                    tags.create(tagName, tagInfo);
                    res.contentType= "application/json";
                    res.statusCode = 201;
                    res.write("{success: true, message: \"Tag %s was created successfully\"}".format(tagName));
                    res.end;
                    return;
                } else {
                    res.statusCode = 200;
                    res.contentType= "application/json";
                    res.write("{success: true, message: \"Tag %s already exists\"}".format(tagName));
                    res.end;
                }
                } catch(Throwable tex) {
                    writeln("POST error " ~ tex.msg);
                    res.contentType= "application/json";
                    res.statusCode = 500;
                    res.write("{success: false, message: \"Error occurred\"}");
                    res.end;
                }
            }; // POST /tags
        }
        int port = 3000;
        string portEnv = environment.get("PORT");
        if(portEnv !is null) {
            port = portEnv.to!int;
        }
        app.serve("0.0.0.0", port);
    };
}
