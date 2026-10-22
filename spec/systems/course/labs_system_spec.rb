require "spec_helper"
require_relative "../../../app/systems/course/labs_system"

RSpec.describe Course::LabsSystem do
  let(:lab) { instance_double("Course::Lab", slug: "red-green", lesson_slug: "test-first") }
  let(:catalog) { instance_double("Course::LabCatalog", labs: [ lab ], find: lab, for_lesson: lab) }
  let(:repository) { instance_double("Course::FileLabRepository", catalog: catalog, files_for: [ { path: "index.js" } ]) }

  it "finds a lab and its starter files" do
    system = described_class.new(repository: repository)

    expect(system.find_lab("red-green")).to eq(lab)
    expect(system.lab_for_lesson("test-first")).to eq(lab)
    expect(system.files_for("red-green")).to eq([ { path: "index.js" } ])
  end
end
