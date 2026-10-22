require "spec_helper"
require_relative "../../support/course_lessons"

RSpec.describe Course::Lesson do
  include CourseLessons

  let(:origin) { "https://school.test" }

  it "exposes its placement, module, and text" do
    lesson = build_lesson(
      slug: "welcome", order: 1, module_name: "Getting started", title: "Welcome", description: "Meet the course."
    )

    expect(lesson).to have_attributes(
      slug: "welcome", order: 1, module_name: "Getting started", title: "Welcome", description: "Meet the course."
    )
    expect(lesson.quiz?).to be(false)
  end

  it "allows a lesson without a module" do
    expect(build_lesson.module_name).to be_nil
  end

  describe "#agent_instructions_for" do
    it "replaces every {origin} placeholder with the given origin" do
      lesson = build_lesson(agent_instructions: "Visit {origin}/a then {origin}/b.")

      expect(lesson.agent_instructions_for(origin: origin))
        .to eq("Visit https://school.test/a then https://school.test/b.")
    end

    it "appends the shared quiz instructions after a blank line for quiz lessons" do
      lesson = build_lesson(quiz: true, agent_instructions: "1. Topic one.")

      expect(lesson.agent_instructions_for(origin: origin))
        .to eq("1. Topic one.\n\n#{Course::QuizInstructions::TEXT}")
    end

    it "does not append quiz instructions for non-quiz lessons" do
      lesson = build_lesson(quiz: false, agent_instructions: "Just verify.")

      expect(lesson.agent_instructions_for(origin: origin)).to eq("Just verify.")
    end
  end

  describe "#body_for" do
    it "replaces every {origin} placeholder in the body" do
      lesson = build_lesson(body: "Read {origin}/llms.txt and {origin}/api/lessons.")

      expect(lesson.body_for(origin: origin))
        .to eq("Read https://school.test/llms.txt and https://school.test/api/lessons.")
    end
  end

  describe "invariants" do
    %i[title description agent_instructions].each do |field|
      it "rejects a blank #{field}" do
        expect { build_lesson(field => " ") }
          .to raise_error(Course::InvalidLesson, /#{field} must be present/)
      end
    end

    it "rejects a blank slug" do
      expect { build_lesson(slug: " ") }.to raise_error(Course::InvalidLesson, /slug must be present/)
    end

    it "rejects a slug that is not lowercase kebab-case" do
      expect { build_lesson(slug: "Welcome Lesson") }
        .to raise_error(Course::InvalidLesson, /slug "Welcome Lesson" must be lowercase kebab-case/)
    end

    it "rejects an order that is not a positive integer" do
      expect { build_lesson(order: 0) }.to raise_error(Course::InvalidLesson, /order must be a positive integer/)
      expect { build_lesson(order: "1") }.to raise_error(Course::InvalidLesson, /order must be a positive integer/)
    end

    it "rejects a quiz flag that is not a boolean" do
      expect { build_lesson(quiz: "yes") }.to raise_error(Course::InvalidLesson, /quiz must be true or false/)
    end
  end
end
