bring cloud;

class Feedreader {
  extern "./feed.mjs" inflight parseAtomFeed(): Json;
  init() { }
}

let githubToken = new cloud.Secret(name: "github-token");
let table = new cloud.Table(name: "feedreader", primaryKey: "id", columns: {
  id: cloud.ColumnType.STRING,
  title: cloud.ColumnType.STRING,
  content: cloud.ColumnType.STRING,
  author: cloud.ColumnType.STRING,
  url: cloud.ColumnType.STRING,
  publishedAt: cloud.ColumnType.DATE,
  createdAt: cloud.ColumnType.DATE,
});
let schedule = new cloud.Schedule(cron: "0 * * * ?");

let feed = new Feedreader();

let scheduleHandler = inflight () => {
  let json = feed.parseAtomFeed();
  log(Json.stringify(json));
};
schedule.onTick(scheduleHandler);

test "parse atom feed" {
  let json = feed.parseAtomFeed();
  log(Json.stringify(json));
}