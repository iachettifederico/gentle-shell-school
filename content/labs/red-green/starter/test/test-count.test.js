const fs = require('node:fs');
const test = require('node:test');
const assert = require('node:assert/strict');

test('includes a test beyond the provided one', () => {
  const tests = fs.readdirSync('test').flatMap((name) => fs.readFileSync(`test/${name}`, 'utf8').match(/\btest\s*\(/g) || []);
  assert.ok(tests.length >= 3, 'add one test of your own');
});
