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

  it "finds the lessons immediately before and after a lesson by order" do
    welcome = lesson("welcome", 1)
    odd = lesson("odd", 2)
    sessions = lesson("sessions", 3)
    catalog = described_class.new([ sessions, welcome, odd ])

    expect(catalog.neighbors_for("odd")).to eq([ welcome, sessions ])
    expect(catalog.neighbors_for("welcome")).to eq([ nil, odd ])
    expect(catalog.neighbors_for("sessions")).to eq([ odd, nil ])
  end

  it "has no neighbors for an unknown lesson" do
    catalog = described_class.new([ lesson("welcome", 1) ])

    expect(catalog.neighbors_for("missing")).to eq([ nil, nil ])
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
