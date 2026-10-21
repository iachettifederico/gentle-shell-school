.ONESHELL:
RAILS = ./bin/rails
GRAPHIFY = graphify
GRAPHIFY_OBSIDIAN_DIR = graphify-out/obsidian

.PHONY: graphify-update
graphify-update:
	$(GRAPHIFY) update .

.PHONY: graphify-obsidian
graphify-obsidian:
	$(MAKE) graphify-update
	$(GRAPHIFY) export obsidian --dir $(GRAPHIFY_OBSIDIAN_DIR)

.PHONY: obsidian-vault
obsidian-vault:
	command -v obsidian >/dev/null || (echo "obsidian binary not found in PATH" && exit 1)
	obsidian $(GRAPHIFY_OBSIDIAN_DIR)

.PHONY: server
server:
	$(RAILS) server -b 0.0.0.0

.PHONY: console
console:
	$(RAILS) console

.PHONY: tailwind
tailwind:
	$(RAILS) tailwindcss:watch

.PHONY: rubocop-correct
rubocop-correct:
	./bin/rubocop --autocorrect-all

.PHONY: quality
quality:
	@echo "Running non-blocking quality checks: rubocop, reek, rubycritic, flay, flog"
	@bundle exec rubocop || true
	@bundle exec reek app || true
	@bundle exec rubycritic app --path tmp/rubycritic --no-browser --format console || true
	@bundle exec flay app || true
	@bundle exec flog app || true
