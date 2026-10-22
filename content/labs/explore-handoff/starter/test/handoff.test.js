const fs = require('node:fs');
const test = require('node:test');
const assert = require('node:assert/strict');

test('handoff cites three real source locations', () => {
  const handoff = fs.readFileSync('handoff.md', 'utf8');
  const references = [...handoff.matchAll(/(src\/[\w/-]+\.js):(\d+)/g)];
  assert.ok(references.length >= 3, 'cite at least three src/path.js:line references');
  references.forEach((match) => {
    const lines = fs.readFileSync(match[1], 'utf8').split('\n');
    assert.ok(Number(match[2]) <= lines.length && Number(match[2]) > 0, `${match[0]} must exist`);
  });
});
