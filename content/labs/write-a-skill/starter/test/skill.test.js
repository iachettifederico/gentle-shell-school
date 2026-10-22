const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');
const assert = require('node:assert/strict');

const sections = ['Activation Contract', 'Hard Rules', 'Decision Gates', 'Execution Steps', 'Output Contract', 'References'];

test('a skill has valid frontmatter and required sections', () => {
  const directory = fs.readdirSync('skills', { withFileTypes: true }).find((entry) => entry.isDirectory());
  assert.ok(directory, 'create skills/<name>/SKILL.md');
  const skill = fs.readFileSync(path.join('skills', directory.name, 'SKILL.md'), 'utf8');
  assert.match(skill, /^---\n[\s\S]*^name: [a-z0-9-]+$[\s\S]*^description: .+$/m);
  sections.forEach((section) => assert.match(skill, new RegExp(`^## ${section}$`, 'm')));
});
