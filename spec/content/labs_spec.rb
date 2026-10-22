require "fileutils"
require "open3"
require "tmpdir"
require "yaml"
require "rails_helper"

RSpec.describe "Lab content" do
  labs = {
    "content/labs"      => %w[feature-document red-green work-unit-commits explore-handoff write-a-skill],
    "content/demo/labs" => %w[demo-hello],
  }

  labs.each do |directory, slugs|
    slugs.each do |slug|
      it "fails on the #{slug} starter and passes with its reference solution" do
        Dir.mktmpdir do |scratch|
          copy_starter(directory, slug, scratch)
          command = lab_check(directory, slug)
          expect(check(command, scratch).last).not_to be_success

          overlay_solution(slug, scratch)
          prepare_git_history(scratch) if slug == "work-unit-commits"
          output, status = check(command, scratch)
          expect(status).to be_success, output
        end
      end
    end
  end

  def copy_starter(directory, slug, scratch)
    copy_contents(Rails.root.join(directory, slug, "starter"), scratch)
  end

  def overlay_solution(slug, scratch)
    copy_contents(Rails.root.join("spec/fixtures/labs", slug, "solution"), scratch)
  end

  def copy_contents(source, destination)
    FileUtils.cp_r(Dir.children(source).map { |name| File.join(source, name) }, destination)
  end

  def prepare_git_history(scratch)
    git_commands.each { |command| expect(run(command, scratch).last).to be_success }
  end

  def git_commands
    [
      "git init", "git config user.email lab@example.test", "git config user.name Lab", "git add .",
      "git commit -m 'feat: make the calculation pass'", "git commit --allow-empty -m 'test: document the check'",
    ]
  end

  def lab_check(directory, slug)
    YAML.safe_load_file(Rails.root.join(directory, slug, "lab.yml")).fetch("check")
  end

  def check(command, scratch)
    run(command, scratch)
  end

  def run(command, scratch)
    Open3.capture2e(command, chdir: scratch)
  end
end
