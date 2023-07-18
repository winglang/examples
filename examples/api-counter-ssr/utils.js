const fs = require('fs')
const path = require('path')
const Handlebars = require('handlebars')

const readFile = function(filePath) {
  const resolvedFilePath = path.join(process.env.WING_SOURCE_DIR, filePath);
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