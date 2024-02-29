import type { IPlatform } from "@winglang/sdk/lib/platform";
import { Aspects } from "cdktf";
import { EnableXray } from "./enable-xray";

export class Platform implements IPlatform {
  public readonly target = "tf-aws";

  preSynth(app: any): void {
    Aspects.of(app).add(new EnableXray(app));
  }
}