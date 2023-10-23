const InputHandler = (function () {
    let mouseIsDown = 0;
    let mouseWasDown = 0;
    let keyInputData = [];
    let mousePos = new Vector2();
    let mousePosWorld = new Vector2();

    oncontextmenu = function (e) {
        e.preventDefault();
    }
    onmousedown = function (e) {
        mouseIsDown = 1;
    }
    onmouseup = function (e) {
        mouseIsDown = 0;
    }
    // onmousemove   = function(e)
    // {
    //     // convert mouse pos to canvas space
    //     let rect = mainCanvas.getBoundingClientRect();
    //     mousePos.Set
    //     (
    //         (e.clientX - rect.left) / rect.width,
    //         (e.clientY - rect.top) / rect.height
    //     ).Multiply(mainCanvasSize);
    // }
    onkeydown = function (e) {
        keyInputData[e.keyCode] = {
            isDown: 1
        };
    }
    onkeyup = function (e) {
        if (keyInputData[e.keyCode]) keyInputData[e.keyCode].isDown = 0;
    }

    function MouseWasPressed() {
        return mouseIsDown && !mouseWasDown;
    }

    function KeyIsDown(key) {
        return keyInputData[key] ? keyInputData[key].isDown : 0;
    }

    function KeyWasPressed(key) {
        return KeyIsDown(key) && !keyInputData[key].wasDown;
    }

    function ClearInput() {
        keyInputData.map(k => k.wasDown = k.isDown = 0);
        mouseIsDown = mouseWasDown = 0;
    }

    return {
        MouseWasPressed,
        KeyIsDown,
        KeyWasPressed,
        ClearInput,
    }
});
