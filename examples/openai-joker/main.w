bring cloud;
bring openai;

// TODO: Set the secret value in the "secrets.json" file (create it if needed) in the ".wing" folder inside your user's folder.
// You need to add an OAIAPIKey like this:
//{
//  "OAIAPIKey": "<your key here>"
//}
// Alternatively, you can set the secret value in the OpenAI constructor directly in line 18, like this:
// this.openai = new openai.OpenAI(apiKey: <your key here>);
let apiKeySecret = new cloud.Secret(name: "OAIAPIKey") as "OpenAI Secret";

class Assistant {
  personality: str;
  openai: openai.OpenAI;

  new(personality: str) {
    this.openai = new openai.OpenAI(apiKeySecret: apiKeySecret);
    this.personality = personality;
  }

  pub inflight ask(question: str): str {
    let prompt = "you are an assistant with the following personality: {this.personality}. {question}";
    let response = this.openai.createCompletion(prompt);

    return response.trim();
  }
}

class Comedian {
  id: cloud.Counter;
  gpt: Assistant;
  store: cloud.Bucket;

  new (store: cloud.Bucket) {
    this.gpt = new Assistant("Stand-up comedian");
    this.id = new cloud.Counter() as "NextID";
    this.store = store;
  }

  pub inflight getJoke(topic: str): str {
    let reply = this.gpt.ask("Tell me a joke about {topic}");
    let n = this.id.inc();
    this.store.put("message-{n}.original.txt", reply);
    return reply;
  }
}

class Translator {
  new(language: str, topic: cloud.Topic, store: cloud.Bucket) {
    let gpt = new Assistant("English to ${language} translator.");
    let id = new cloud.Counter() as "NextID";

    topic.onMessage(inflight (original: str) => {
      let n = id.inc();

      log("translating joke id {n} to {language}");
      let translated = gpt.ask("Please translate the following text: {original}");
      
      store.put("{language}/message-{n}.translated.txt", translated);
      log("written joke id {n} in {language}");
    });
  }
}

let store = new cloud.Bucket() as "Joke Store";
let newJokeSource = new cloud.Topic() as "New Joke";

let comedian = new Comedian(store) as "Comedian";

new Translator("spanish", newJokeSource, store) as "Spanish Translator";
new Translator("hebrew", newJokeSource, store) as "Hebrew Translator";

new cloud.Function(inflight () => {
  let topic = "programming languages";
  log("requesting a joke about ${topic}");
  let joke = comedian.getJoke(topic);
  log("publishing joke: ${joke}");
  newJokeSource.publish(joke);
}) as "START HERE";