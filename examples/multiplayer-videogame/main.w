bring cloud;
bring util;
bring ex;

let website = new cloud.Website(path: "./front-end");

class Utils {
    extern "./socket_utils.js" pub static inflight RunWebSocketServer(port:num);
    extern "./socket_utils.js" pub static inflight CloseWebSocketServer(port:num);
    init() { }
}

let lock = new cloud.Counter(
    initial: 0,
) as "server lock";

let runWebsocketServer = inflight (port:num) => {
    if(lock.peek() == 0){
        log("Starting WebSocket server");
        Utils.RunWebSocketServer(port);
        lock.inc();
    }
};

let stopWebsocketServer = inflight (port:num) => {
    if(lock.peek() != 0){
        log("Stopping the server");
        Utils.CloseWebSocketServer(port);
        lock.set(0);
    }
};

let handler = inflight() => {
    let port:num = 27326;
    runWebsocketServer(port);
    return () => {
        stopWebsocketServer(port);
    };
};

let service = new cloud.Service(handler, autoStart: false) as "main lobby";

// Unit tests:
test "server should start" {
    service.start();
    assert(lock.peek() == 1);
    service.stop();
}

test "server should not be restarted when already running" {
    service.start();
    service.start();
    service.start();

    assert(lock.peek() == 1); // max 1 server
    service.stop();
}

test "server should be stopped" {
    service.start();
    assert(lock.peek() == 1);
    service.stop();
    assert(lock.peek() == 0);
}

test "server should not be stopped when not running" {
    service.stop();
    assert(lock.peek() == 0);
}

test "server should be restarted after being stopped" {
    service.start();
    assert(lock.peek() == 1);
    service.stop();
    assert(lock.peek() == 0);
    service.start();
    assert(lock.peek() == 1);
    service.stop();
}