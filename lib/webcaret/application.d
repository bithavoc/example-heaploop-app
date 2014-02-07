module webcaret.application;

import webcaret.router;
import heaploop.networking.http;
import std.string : format;
import std.stdio : writeln;

class Application {
    private:
        Router!HttpContext _router;
    public:
        this() {
            _router = new Router!HttpContext;
        }

        @property {
            Router!HttpContext router() nothrow {
                return _router;
            }
        }

        void serve(string address, int port) {
            auto server = new HttpListener;
            server.bind4(address, port);
            "listening http://%s:%d".format(address, port).writeln;
            server.listen ^^ (connection) {
                debug writeln("HTTP Agent just connected");
                connection.process ^^ (request, response) {
                    _router.execute(request.method, request.uri.path, request.context);
                };
            };
        }
}

