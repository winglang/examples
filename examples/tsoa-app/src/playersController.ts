import {
  Body,
  Controller,
  Get,
  Path,
  Post,
  Query,
  Route,
  SuccessResponse,
  Request
} from "tsoa";

import {
  Request as RequestExpress,
} from "express";

import { getClient } from "@winglibs/tsoa/clients.js"

import { IBucketClient, IFunctionClient } from "@winglang/sdk/lib/cloud";

export interface Player {
  id: string;
  team: string;
  name: string;
}

export interface PlayerCreationParams {
  team?: string;
  name: string;
}

@Route("players")
export class UsersController extends Controller {
  @Get("{playerId}")
  public async getUser(
    @Path() playerId: string,
    @Request() request: RequestExpress
  ): Promise<Player | undefined> {
    const store: IBucketClient = getClient(request, "playersStore");
    const player = await store.tryGet(playerId);
    if (!player) {
      this.setStatus(404);
      return;
    }
    return JSON.parse(player);
  }

  @SuccessResponse("201", "Created") // Custom success response
  @Post()
  public async createUser(
    @Body() requestBody: PlayerCreationParams,
    @Request() request: RequestExpress
  ): Promise<void> {
    this.setStatus(201);
    const playerId = Math.random().toString().slice(-6);
    let team = requestBody.team;
    if (!team) {
      const getTeamByPlayerId: IFunctionClient = getClient(request, "getTeamByPlayerId");
      team = await getTeamByPlayerId.invoke(playerId) as number
    }
    const store = getClient(request, "playersStore");
    const player: Player = {
      id: playerId,
      team,
      name: requestBody.name,
    }
    await store.put(player.id, JSON.stringify(player));
    return;
  }
}