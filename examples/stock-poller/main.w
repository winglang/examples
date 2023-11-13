bring cloud;
bring http;

let tickerSymbol = "GME";

class TwelveDataApi {
    key: cloud.Secret;

    init() {
        this.key = new cloud.Secret(
          name: "twelve-data-api-key"
        );
    }

    pub inflight stockUpdates(tickerSymbol: str): http.Response {
        return http.get("https://api.twelvedata.com/time_series?symbol=${tickerSymbol}&interval=1min&outputsize=1&apikey=${this.key.value()}");
    }
}

let recentStockPriceCache = new cloud.Counter(
  initial: 0
);

let stockUpdatesQueue = new cloud.Queue();
let twelveDataApi = new TwelveDataApi();

let stockUpdatesFetchSchedule = new cloud.Schedule(rate: 2m);       // Twelve Data free tier gives you 800 API credits per day. So with a rate of 2 minutes, you use 720 API credits per day
let stockUpdatesPoller = stockUpdatesFetchSchedule.onTick(inflight () => {
  let stockUpdates = twelveDataApi.stockUpdates(tickerSymbol);

  log("Status: ${stockUpdates.status}");
  log("Body: ${stockUpdates.body}");

  let stockUpdatesBody = stockUpdates.body;
  
  log("Received this stock updates: ${stockUpdatesBody}");

  let stockUpdatesBodyJson = Json.parse(stockUpdatesBody);
  let latestStockPriceStr = stockUpdatesBodyJson.get("values").getAt(0).get("close").asStr();
  let latestStockPrice = num.fromStr(latestStockPriceStr);

  let previousStockPrice = recentStockPriceCache.peek(tickerSymbol);
  log("Stock price for ${tickerSymbol} changed from ${previousStockPrice} to ${latestStockPrice} with a difference of: ${latestStockPrice - previousStockPrice}");

  recentStockPriceCache.set(latestStockPrice, tickerSymbol);
  stockUpdatesQueue.push(stockUpdatesBody);
  
    
});
