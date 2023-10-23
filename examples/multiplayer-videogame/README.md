# Wingcloud Paintball

A very simple websoket broadcasting server for a multiplayer paintball game.

![ScreencastPaintball.gif](images%2FScreencastPaintball.gif)

## Description

This is a multiplayer paintball game made with Wingcloud and VanillaJs.

![img.png](images/infra2.png)

## Infrastructure With Code

The infrastructure is composed by:
- A [cloud.Website](https://www.winglang.io/docs/standard-library/cloud/website) to host the website
- A [cloud.Service](https://www.winglang.io/docs/standard-library/cloud/secret) as a websocket broadcasting server


## Next Steps
- A [cloud.Api](https://www.winglang.io/docs/standard-library/cloud/api) for creating new lobbies and joining them
- A [inflight functions](https://www.winglang.io/docs/concepts/inflights) to handle the API calls for the creation of new lobbies (Spinning new cloud.Services)
- A [redis database](https://www.winglang.io/docs/standard-library/ex/redis) for storing in-memory info of the players and the lobbies

## Run the example

```bash
npm i
```

Make sure you have Docker installed and running.

```bash
wing it main.w
```