const test = require('node:test');
const assert = require('node:assert/strict');
const { hello } = require('../src/hello');

test('says hello', () => {
  assert.equal(hello(), 'Hello');
});
