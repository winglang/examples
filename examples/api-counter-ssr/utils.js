const fs = require('fs')
const path = require('path')
const Handlebars = require('handlebars')

const readFile = function(filePath) {
  const resolvedFilePath = path.join(process.cwd(), filePath);
  return fs.readFileSync(resolvedFilePath, 'utf-8');
}

const render = function(template, count) {
  const compiled = Handlebars.compile(template);
  return compiled({ count });
}

module.exports = {
  readFile,
  render
}