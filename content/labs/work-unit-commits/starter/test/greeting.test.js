const { execFileSync } = require('node:child_process');
const test = require('node:test');
const assert = require('node:assert/strict');
const { greeting } = require('../src/greeting');

test('formats a friendly greeting', () => {
  assert.equal(greeting('Ada'), 'Hello Ada');
});

test('has two Conventional Commit work units', () => {
  let messages;
  try {
    messages = execFileSync('git', ['log', '--format=%s'], { encoding: 'utf8' });
  } catch {
    assert.fail('run git init before checking your commits');
  }
  const commits = messages.trim().split('\n').filter((message) => /^(feat|fix|test|docs|refactor|chore)(\(.+\))?!?: /.test(message));
  assert.ok(commits.length >= 2, 'create at least two Conventional Commit commits');
});
