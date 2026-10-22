require "spec_helper"
require "tmpdir"
require_relative "../../../app/domain/course/invalid_lesson"
require_relative "../../../app/domain/course/lab"
require_relative "../../../app/domain/course/lab_catalog"
require_relative "../../../app/adapters/course/file_lab_repository"

RSpec.describe Course::FileLabRepository do
  around do |example|
    Dir.mktmpdir do |dir|
      @dir = dir
      example.run
    end
  end

  it "loads a lab and recursively exposes its starter files" do
    lab_dir = File.join(@dir, "red-green")
    FileUtils.mkdir_p(File.join(lab_dir, "starter", "test"))
    File.write(File.join(lab_dir, "lab.yml"), <<~YAML)
      slug: red-green
      lesson: test-first
      title: Red, green
      brief: Make the test pass.
      check: node --test
      rubric:
        - Tests pass.
    YAML
    File.write(File.join(lab_dir, "starter", "index.js"), "module.exports = {};\n")
    File.write(File.join(lab_dir, "starter", "test", "index.test.js"), "// test\n")

    repository = described_class.new(directory: @dir)

    expect(repository.catalog.find("red-green").title).to eq("Red, green")
    expect(repository.files_for("red-green")).to eq(
      [
        { path: "index.js", content: "module.exports = {};\n" },
        { path: "test/index.test.js", content: "// test\n" },
      ]
    )
  end
  it "never serves symlinked files or files outside the starter directory" do
    secret = File.join(@dir, "secret.txt")
    File.write(secret, "do not serve\n")
    starter = File.join(@dir, "leaky", "starter")
    FileUtils.mkdir_p(File.join(starter, "nested"))
    File.write(File.join(starter, "index.js"), "ok\n")
    File.symlink(secret, File.join(starter, "link.txt"))
    File.symlink(@dir, File.join(starter, "nested", "up"))

    files = described_class.new(directory: @dir).files_for("leaky")

    expect(files).to eq([ { path: "index.js", content: "ok\n" } ])
  end
end
