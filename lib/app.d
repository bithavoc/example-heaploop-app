import webcaret.application;
import heaploop.looping;

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
        app.serve("0.0.0.0", 3000);
    };
}
