// copied from here https://github.com/winglang/wing-github-action/blob/c0a37fd14067ab356791cfdcbc77ee59ba2561fa/actions/deploy/plugins/backend.s3.js
/**
 * This plugin will configure the backend to use S3 for storing state. The configuration
 * is dynamically done externally.
 *
 */

exports.postSynth = function(config) {
  config.terraform.backend = {
    // needs an empty object to be configurable from the outside
    s3: {}
  }
  return config;
}