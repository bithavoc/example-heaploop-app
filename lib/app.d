import webcaret.application;
import heaploop.looping;
import std.string : format;
import couched;
import std.json;

void main() {
    loop ^^ {
        auto client = new CouchedClient("http://127.0.0.1:5984");
        CouchedDatabase tags = client.databases.tags;
        tags.ensure();
        auto app = new Application;
        with(app.router) {
            get("/") ^ (req, res) {
                res.write(r"
                        <html>
                            <body>
                                <h1>Deeq API</h1>
                            </body>
                        </html>" ~ "\r\n");
                res.end;
            };

            // curl -X POST -d "name=business" 0.0.0.0:3000/tags
            post("/tags") ^ (req, res) {
                string tagName = null;
                if("name" in req.form) {
                    tagName = req.form["name"];
                } else {
                    res.statusCode = 422;
                    res.contentType= "application/json";
                    res.write("{success: false, message: \"Tag name is required\"}");
                    res.end;
                    return;
                }
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
                    res.statusCode = 201;
                    res.write("{success: true, message: \"Tag %s was created successfully\"}".format(tagName));
                    res.end;
                    return;
                } else {
                    res.statusCode = 200;
                    res.write("{success: true, message: \"Tag %s already exists\"}".format(tagName));
                    res.end;
                }
            };
        }
        app.serve("0.0.0.0", 3000);
    };
}
