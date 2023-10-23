bring cloud;
bring util;
bring ex;

let website = new cloud.Website(path: "./front-end");

class Utils {
    extern "./socket_utils.js" pub static inflight RunWebSocketServer();
    extern "./socket_utils.js" pub static inflight CloseWebSocketServer();
    init() { }
}

let lock = new cloud.Counter(
    initial: 0,
) as "server lock";

let handler = inflight() => {
    log("Starting WebSocket server");
    if(lock.peek() == 0){
        lock.inc();
        Utils.RunWebSocketServer();
    }
    return () => {
        log("Stopping the server");
        Utils.CloseWebSocketServer();
        lock.dec();
    };
};

let service = new cloud.Service(handler, autoStart: true) as "main lobby";