
const ModelHelper = (function() {

    let allPlayers = {};
    let playerId = null;

    function SetPlayerPosition(playerId, position) {
        if(!allPlayers[playerId]) {
            allPlayers[playerId] = {};
        }
        allPlayers[playerId].position = position;
    }

    function IncPlayerPosition(x, y) {
        if(!allPlayers[playerId]) {
            allPlayers[playerId] = {};
        }
        allPlayers[playerId].position = allPlayers[playerId]
            .position
            .Add(new Vector2(x, y));

        return allPlayers[playerId]
            .position;
    }

    function SetPlayerData(playerId, data) {
        if(!allPlayers[playerId]) {
            allPlayers[playerId] = {};
        }
        allPlayers[playerId] = {
            ...allPlayers[playerId],
            ...data
        }
    }

    function ListAllPlayers() {
        return Object.values(allPlayers);
    }

    return {
        SetPlayerPosition,
        ListAllPlayers,
        SetPlayerData,
        IncPlayerPosition,
        InitMyPlayer: (myId) => {
            playerId = myId;
            allPlayers[playerId] = {
                id: playerId,
                position: new Vector2(0, 0),
                speed: 2,
                color: 'green',
                radius: 10,
                name: playerId,
            }
            console.log('My player id is', allPlayers[playerId])
        },
        GetPlayer() {
            return allPlayers[playerId]
        }
    }
});