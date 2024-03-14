const openai = require('openai');
const fs = require("fs");
const path = require("path");
const os = require("os");

// Uncomment one of the below two lines for the api key
// const apiKey = fs.readFileSync(path.join(os.homedir(), ".openai-api-key"), "utf-8").trim();
// const apiKey = "<your api key here>"; 

// Uncomment the below line for the organization id (optional)
// const org = fs.readFileSync(path.join(os.homedir(), ".openai-org"), "utf-8").trim();
// const org = "<your org id here>";

exports.createCompletion = async (prompt) => {
  const config = {
    apiKey,
  };
  if (org) {
    config.organization = org;
  }

  const api = new openai.OpenAI(config);

  const response = await api.chat.completions.create({
    model: "gpt-3.5-turbo",
    max_tokens: 2048,
    messages: [{role: 'user', content: prompt}],
  });

  return response.choices[0]?.message?.content;
};