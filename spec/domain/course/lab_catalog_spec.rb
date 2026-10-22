require "spec_helper"
require_relative "../../../app/domain/course/invalid_lesson"
require_relative "../../../app/domain/course/lab"
require_relative "../../../app/domain/course/lab_catalog"

RSpec.describe Course::LabCatalog do
  def lab(slug, lesson_slug)
    Course::Lab.new(
      slug: slug, lesson_slug: lesson_slug, title: slug, brief: "Brief", check: "node --test", rubric: [ "Pass" ]
    )
  end

  it "finds labs by slug and lesson" do
    catalog = described_class.new([ lab("red-green", "test-first"), lab("feature-document", "feature-tracking") ])

    expect(catalog.find("red-green").lesson_slug).to eq("test-first")
    expect(catalog.for_lesson("feature-tracking").slug).to eq("feature-document")
  end

  it "rejects duplicate lesson labs" do
    expect { described_class.new([ lab("first", "lesson"), lab("second", "lesson") ]) }
      .to raise_error(Course::InvalidLesson, /duplicate lab lesson "lesson"/)
  end
end
