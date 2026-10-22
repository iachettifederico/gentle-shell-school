const test = require('node:test');
const assert = require('node:assert/strict');
const { double } = require('../src/double');

test('doubles a positive number', () => {
  assert.equal(double(4), 8);
});
