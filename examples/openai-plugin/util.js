exports.getIssues = async function () {
  const fetch = await import('node-fetch');
  const url = 'https://api.github.com/repos/winglang/wing/issues?sort=created&direction=desc&labels=%F0%9F%99%8B%E2%80%8D%E2%99%80%EF%B8%8F%20help%20wanted&per_page=10';

  try {
    const response = await fetch.default(url);

    if (response.ok) {
      return await response.json();
    } else {
      throw new Error(`Unexpected response status: ${response.status}`);
    }
  } catch (error) {
    console.error(`Failed to fetch issues: ${error.message}`);
  }
}

const fs = require('fs');
const path = require('path');

exports.readFile = function (filePath) {
  const resolvedFilePath = path.join(process.env.WING_SOURCE_DIR, filePath);
  return fs.readFileSync(resolvedFilePath, 'utf-8');
}
