require "spec_helper"
require_relative "../../support/course_lessons"

RSpec.describe Course::Catalog do
  include CourseLessons

  def lesson(slug, order)
    build_lesson(slug: slug, order: order, title: slug.capitalize)
  end

  it "lists lessons sorted by order" do
    catalog = described_class.new([ lesson("sessions", 3), lesson("welcome", 1), lesson("odd", 2) ])

    expect(catalog.lessons.map(&:slug)).to eq(%w[welcome odd sessions])
  end

  it "finds a lesson by slug" do
    catalog = described_class.new([ lesson("welcome", 1), lesson("odd", 2) ])

    expect(catalog.find("odd").title).to eq("Odd")
  end

  it "returns nil for an unknown slug" do
    catalog = described_class.new([ lesson("welcome", 1) ])

    expect(catalog.find("missing")).to be_nil
  end

  it "rejects duplicate slugs" do
    expect { described_class.new([ lesson("welcome", 1), lesson("welcome", 2) ]) }
      .to raise_error(Course::InvalidLesson, /duplicate lesson slug "welcome"/)
  end

  it "rejects duplicate orders" do
    expect { described_class.new([ lesson("welcome", 1), lesson("odd", 1) ]) }
      .to raise_error(Course::InvalidLesson, /duplicate lesson order 1/)
  end
end
