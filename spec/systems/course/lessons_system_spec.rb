require "spec_helper"
require_relative "../../support/course_lessons"
require_relative "../../../app/systems/course/lessons_system"

RSpec.describe Course::LessonsSystem do
  include CourseLessons

  let(:welcome) { build_lesson(slug: "welcome") }
  let(:repository) { instance_double("Course::FileLessonRepository", catalog: Course::Catalog.new([ welcome ])) }
  let(:system) { described_class.new(repository: repository) }

  it "lists the catalog lessons" do
    expect(system.lessons).to eq([ welcome ])
  end

  it "finds a lesson by slug" do
    expect(system.find_lesson("welcome")).to eq(welcome)
  end

  it "returns nil for an unknown slug" do
    expect(system.find_lesson("missing")).to be_nil
  end
end
