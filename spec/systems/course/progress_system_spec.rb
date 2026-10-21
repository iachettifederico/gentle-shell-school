require "rails_helper"
require_relative "../../support/lesson_fixtures"

RSpec.describe Course::ProgressSystem do
  include LessonFixtures

  let(:clock) { -> { Time.utc(2025, 1, 2, 12) } }
  let(:id_generator) { class_double(Course::StudentId, generate: "curious-hacker-2019") }
  let(:repository) { Course::ActiveRecordProgressRepository.new }
  let(:lessons_system) {
    Course::LessonsSystem.new(
      repository: Course::FileLessonRepository.new(directory: Rails.configuration.x.lessons_directory)
    )
  }
  let(:system) {
    described_class.new(
      repository:     repository,
      lessons_system: lessons_system,
      id_generator:   id_generator,
      clock:          clock
    )
  }

  def lessons(&)
    files = {
      "01-welcome.md" => lesson_markdown(slug: "welcome", order: 1, title: "Welcome", body: "# Welcome"),
    }
    with_lessons(files, &)
  end

  it "enrolls a student with an empty progress record" do
    progress = system.enroll

    expect(progress.created_at).to eq(Time.utc(2025, 1, 2, 12))
    expect(progress.completions).to eq([])
    expect(Student.pluck(:public_id)).to eq([ "curious-hacker-2019" ])
  end

  it "retries an identifier collision up to a successful enrollment" do
    Student.create!(public_id: "curious-hacker-2019")
    allow(id_generator).to receive(:generate).and_return("curious-hacker-2019", "bright-maker-2020")

    progress = system.enroll

    expect(progress.student_id).to eq("bright-maker-2020")
  end

  it "fails loudly after 10 colliding identifiers without creating a student" do
    Student.create!(public_id: "curious-hacker-2019")
    allow(id_generator).to receive(:generate).and_return("curious-hacker-2019")

    expect { system.enroll }
      .to raise_error(Course::EnrollmentFailed, "Could not generate a unique student ID after 10 attempts")
    expect(id_generator).to have_received(:generate).exactly(10).times
    expect(Student.count).to eq(1)
  end

  it "completes a catalog lesson with normalized metadata" do
    lessons do
      progress = system.enroll
      completed = system.complete_lesson(
        progress.student_id, lesson_slug: "welcome", source: "agent", model: "  gpt-5  "
      )

      completion = completed.completions.first
      expect([ completion.slug, completion.source, completion.model ]).to eq(%w[welcome agent gpt-5])
    end
  end

  it "rejects an unknown lesson without changing stored progress" do
    progress = system.enroll

    expect { system.complete_lesson(progress.student_id, lesson_slug: "missing", source: "browser", model: nil) }
      .to raise_error(Course::UnknownLesson, 'Unknown lesson slug: "missing"')
    expect(system.progress_for(progress.student_id).completions).to eq([])
  end

  it "uncompletes one known lesson and resets known completions" do
    lessons do
      progress = system.enroll
      system.complete_lesson(progress.student_id, lesson_slug: "welcome", source: "browser", model: nil)

      expect(system.uncomplete_lesson(progress.student_id, lesson_slug: "welcome").completions).to eq([])
      expect(system.reset(progress.student_id).completions).to eq([])
    end
  end

  it "exposes domain errors for invalid and unknown students" do
    expect { system.progress_for("invalid") }
      .to raise_error(Course::InvalidStudentId, "Invalid student ID format")
    expect { system.progress_for("curious-hacker-2019") }
      .to raise_error(Course::StudentNotFound, "Student not found")
  end
end
