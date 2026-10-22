const fs = require('node:fs');
const test = require('node:test');
const assert = require('node:assert/strict');

test('the feature document preserves its request and structure', () => {
  const document = fs.readFileSync('odd/tasks/lesson-search.md', 'utf8');
  assert.match(document, /^## Specs$/m);
  assert.match(document, /^## Tasks$/m);
  assert.match(document, /^## Log$/m);
  assert.match(document, /> "Add a search box that filters the course lessons by title\."/);
});
