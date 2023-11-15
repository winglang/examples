// main.js

const http = require('http');
const express = require('express');
const socketIO = require('socket.io');
const DEFAULT_PORT = 27326;

const servers = {};

function RunWebSocketServer(port) {

    const app = express();
    const server = http.createServer(app);

    servers[port??DEFAULT_PORT] = server;

    try {
        const io = socketIO(server, {
            cors: {
                origin: '*',
            },
            handlePreflightRequest: (req, res) => {
                const headers = {
                    "Access-Control-Allow-Headers": "Content-Type, Authorization",
                    "Access-Control-Allow-Origin": req.headers.origin, //or the specific origin you want to give access to,
                    "Access-Control-Allow-Credentials": true
                };
                res.writeHead(200, headers);
                res.end();
            }
        });

        io.on('connection', (socket) => {
            console.log('A client has connected.');

            socket.on('playerMove', (data) => {
                socket.broadcast.emit('playerPositionUpdate', data);
            });

            socket.on('disconnect', () => {
                console.log('A client has disconnected.');
            });
        });

        server.listen(port??DEFAULT_PORT, () => {
            console.log(`WebSocket server is running on port ${port??DEFAULT_PORT}`);
        });
    }catch (e) {
        console.log(e);
    }
}
function CloseWebSocketServer(port) {
    servers[port??DEFAULT_PORT]?.close((err) => {
        if (err) {
            console.log(err);
            return;
        }
        console.log('Server is closed.');
    });
}

module.exports = {
    RunWebSocketServer,
    CloseWebSocketServer
}