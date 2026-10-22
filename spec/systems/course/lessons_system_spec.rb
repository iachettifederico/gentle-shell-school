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

  it "groups lessons by module in lesson order" do
    foundations = build_lesson(slug: "layers", order: 2, module_name: "Foundations")
    introduction = build_lesson(slug: "welcome", order: 1, module_name: "Getting started")
    catalog = Course::Catalog.new([ foundations, introduction ])
    repository = instance_double("Course::FileLessonRepository", catalog: catalog)

    groups = described_class.new(repository: repository).lesson_groups

    expect(groups.map { |name, lessons| [ name, lessons.map(&:slug) ] })
      .to eq([[ "Getting started", [ "welcome" ] ], [ "Foundations", [ "layers" ] ]])
  end

  it "finds a lesson by slug" do
    expect(system.find_lesson("welcome")).to eq(welcome)
  end

  it "returns nil for an unknown slug" do
    expect(system.find_lesson("missing")).to be_nil
  end
end
