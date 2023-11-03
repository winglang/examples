const ViewHelper = (function () {

    const canvas = document.getElementById('c1');
    const ctx = canvas.getContext('2d');

    // TODO: Camera should always SLerp follow the player
    let cameraPos = new Vector2();

    function DrawRectangle(x, y, width, height, color) {
        ctx.fillStyle = color;
        ctx.fillRect(x, y, width, height);
    }

    function DrawCircle(x, y, radius, color) {
        ctx.fillStyle = color;
        ctx.beginPath();
        ctx.arc(x, y, radius, 0, 2 * Math.PI);
        ctx.fill();
    }

    function DrawBg() {
        DrawRectangle(0, 0, canvas.width, canvas.height, 'white');
    }

    function DrawCurrentFrame(allPlayers) {
        const objectsToDraw = allPlayers

        DrawBg();

        objectsToDraw.forEach(player => {
            // shift player based on camera position
            // player.x += cameraPos.x;
            // player.y += cameraPos.y;
            DrawCircle(
                player.position.x,
                player.position.y,
                player.radius ?? 10,
                player.color ?? 'red'
            );
        });
    }

    return {
        DrawCurrentFrame: DrawCurrentFrame,
    }

});