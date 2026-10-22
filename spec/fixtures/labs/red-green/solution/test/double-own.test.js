const test = require('node:test');
const assert = require('node:assert/strict');
const { double } = require('../src/double');

test('doubles zero', () => {
  assert.equal(double(0), 0);
});
