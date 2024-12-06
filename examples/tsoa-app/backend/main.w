bring cloud;
bring tsoa;
bring aws;
bring util;

// create a AWS function
if util.env("WING_TARGET") == "tf-aws" {
  bring "cdktf" as cdktf;
  let getTeamByPlayerId = new cloud.Function(inflight (payload) => {
    if let playerId = payload {
      if num.fromStr(playerId) % 2 == 0 {
        return "Blue Team";
      } else {
        return "Red Team";
      }
    }

    return "Green Team";
  });
  
  new cdktf.TerraformOutput(value: aws.Function.from(getTeamByPlayerId)?.functionArn);
} else {
  let playersStore = new cloud.Bucket();
  let service = new tsoa.Service(
    controllerPathGlobs: ["../src/*Controller.ts"],
    outputDirectory: "../build",
    routesDir: "../build"
  );
  
  service.liftClient("playersStore", playersStore, ["tryGet", "put"]);

  // get the function ARN after deploying it
  let getTeamByPlayerId = new aws.FunctionRef("") as "getTeamByPlayerId";
  service.liftClient("getTeamByPlayerId", getTeamByPlayerId, ["invoke"]);
}

