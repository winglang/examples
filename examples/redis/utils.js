const { v4: uuidv4 } = require('uuid');

exports.uuid = function() {
  return uuidv4();
}