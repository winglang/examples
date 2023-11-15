export function base64decode(str) {
  return Buffer.from(str, 'base64').toString('utf8');
}

export function base64encode(str) {
  return Buffer.from(str, 'utf8').toString('base64');
}
