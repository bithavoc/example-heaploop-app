import webcaret.application;
import heaploop.looping;
import std.string : format;

void main() {
    loop ^^ {
        auto app = new Application;
        app.router.get("/") ^ (req, res) {
            res.write(r"
                    <html>
                        <body>
                            <h1>Deeq API</h1>
                        </body>
                    </html>" ~ "\r\n");
            res.end;
        };

        // curl -X POST -d "name=business" 0.0.0.0:3000/tags
        app.router.post("/tags") ^ (req, res) {
            auto tagName = req.form["name"];
            res.statusCode = 201;
            res.write("{success: true, message: \"Tag %s was created successfully\"}".format(tagName));
            res.end;
        };
        app.serve("0.0.0.0", 3000);
    };
}
