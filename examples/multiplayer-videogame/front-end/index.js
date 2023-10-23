////////////// INPUT KEYBOARD //////////////
const input = InputHandler();

////////////// MODEL HELPER //////////////
const model = ModelHelper();

////////////// ENGINE INIT //////////////
const view = ViewHelper();

////////////// ENGINE LOOP //////////////
const EngineLoop = (function (socket) {

    model.InitMyPlayer(socket.id);

    function RefreshScreen() {
        const playerSpeed = model.GetPlayer().speed;
        let positionHasChanged = false;

        // Key Left
        if(input.KeyIsDown(37) || input.KeyIsDown(65)) {
            positionHasChanged = model.IncPlayerPosition(
                -playerSpeed, 0
            );
        }

        // Key Up
        if(input.KeyIsDown(38) || input.KeyIsDown(87)) {
            positionHasChanged = model.IncPlayerPosition(
                0, -playerSpeed
            );
        }

        // Key Right
        if(input.KeyIsDown(39) || input.KeyIsDown(68)) {
            positionHasChanged = model.IncPlayerPosition(
                +playerSpeed, 0
            );
        }

        // Key Down
        if(input.KeyIsDown(40) || input.KeyIsDown(83)) {
            positionHasChanged = model.IncPlayerPosition(
                0, +playerSpeed
            );
        }

        if(!!positionHasChanged){
            // FIXME: to avoid teleportation use 'left'/ 'right' / 'up' / 'down'
            socket.emit('playerMove', {
                id: model.GetPlayer().id,
                x : model.GetPlayer().position.x,
                y : model.GetPlayer().position.y,
            });
        }

        view.DrawCurrentFrame(model.ListAllPlayers());
        requestAnimationFrame(RefreshScreen);
    }

    return {
        RefreshScreen: RefreshScreen
    }
});


////////////// SOCKET IO //////////////

const socket = io('http://localhost:27326');
socket.on('connect', () => {
    console.log(`Connected to the server with id ${socket.id}`);
    EngineLoop(socket)
        .RefreshScreen();

    socket.on('playerPositionUpdate', (data) => {
        model.SetPlayerPosition(
            data.id,
            new Vector2(data.x, data.y)
        );
    });

});

socket.on('disconnect', () => {
    console.log('Disconnected from the server.');
});
