require "spec_helper"
require_relative "../../../app/domain/course/invalid_lesson"
require_relative "../../../app/domain/course/lab"

RSpec.describe Course::Lab do
  it "keeps the lab contract" do
    lab = described_class.new(
      slug: "red-green", lesson_slug: "test-first", title: "Red, green", brief: "Make it pass.",
      check: "node --test", rubric: [ "Tests pass." ]
    )

    expect(lab.slug).to eq("red-green")
    expect(lab.lesson_slug).to eq("test-first")
    expect(lab.rubric).to eq([ "Tests pass." ])
  end

  it "rejects a lab without a check" do
    expect {
      described_class.new(
        slug: "red-green", lesson_slug: "test-first", title: "Red", brief: "Brief", check: "", rubric: [ "Pass" ]
      )
    }.to raise_error(Course::InvalidLesson, "lab check must be present")
  end
end
